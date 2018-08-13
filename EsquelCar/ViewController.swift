//
//  ViewController.swift
//  EsquelCar
//
//  Created by KL on 7/7/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {

    @IBOutlet var leftDirectionSwitch: UISwitch!
    @IBOutlet var rightDirectionSwitch: UISwitch!
    @IBOutlet var leftMoveSwitch: UISwitch!
    @IBOutlet var rightMoveSwitch: UISwitch!
    @IBOutlet var statusLabel: UILabel!
    
    
    var centralManager: CBCentralManager?
    var peripheral: CBPeripheral? {
        didSet{
            peripheral?.delegate = self
            if peripheral != nil{
                centralManager?.connect(peripheral!)
            }
            
        }
    }
    var characteristic: CBCharacteristic?
    
    let deviceName = "EsquelCar\r\n"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initBluetoothService()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func stopOnClicked(_ sender: Any) {
        if let characteristic = characteristic, let peripheral = peripheral{
            peripheral.writeValue(Data(bytes: [16]), for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
        }
    }
    
    @IBAction func sendOnClicked(_ sender: Any) {
        var value: UInt8 = 0
        
        if leftDirectionSwitch.isOn{
            value += 1
        }
        
        if rightDirectionSwitch.isOn{
            value += 4
        }
        
        if leftMoveSwitch.isOn{
            value += 2
        }
        
        if rightMoveSwitch.isOn{
            value += 8
        }
        
        if let characteristic = characteristic, let peripheral = peripheral{
            peripheral.writeValue(Data(bytes: [value]), for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
        }
        
    }
    
}

extension ViewController: CBCentralManagerDelegate{
    
    func initBluetoothService(){
        let centralQueue: DispatchQueue = DispatchQueue(label: "com.iosbrain.centralQueueName", attributes: .concurrent)
        centralManager = CBCentralManager(delegate: self, queue: centralQueue)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("Bluetooth status is UNKNOWN")
        case .resetting:
            print("Bluetooth status is RESETTING")
        case .unsupported:
            print("Bluetooth status is UNSUPPORTED")
        case .unauthorized:
            print("Bluetooth status is UNAUTHORIZED")
        case .poweredOff:
            print("Bluetooth status is POWERED OFF")
        case .poweredOn:
            print("Bluetooth status is POWERED ON")
            DispatchQueue.main.async {
                self.centralManager?.scanForPeripherals(withServices: nil)
            }
            return
        }
        
        DispatchQueue.main.async {
            self.statusLabel.text = "Please turn on bluetooth"
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if deviceName == peripheral.name{
            self.peripheral = peripheral
            print("Car founded")
            DispatchQueue.main.async { () -> Void in
                self.statusLabel.text = "Connected to Esquel Car, you can send command now"
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        DispatchQueue.main.async { () -> Void in
            // connected
            peripheral.discoverServices(nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected")
        DispatchQueue.main.async { () -> Void in
            // disconnected
            self.statusLabel.text = "Disconnected. Please connect it again."
            self.peripheral = nil
            self.centralManager?.scanForPeripherals(withServices: nil)
        }
    }
}

extension ViewController: CBPeripheralDelegate{
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else {
            return
        }
        if let service = services.last{
            print("*******************************************************")
            print("Found Service: \(service)")
            print("*******************************************************")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else {
            return
        }
        
        print("Found \(characteristics.count) characteristics!")
        for characteristic in characteristics {
            print("-------------------------------------------------------")
            print("Founded Characteristic: \(characteristic)")
            print("-------------------------------------------------------")
            self.characteristic = characteristic
            peripheral.writeValue(Data(bytes: [14]), for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
        }
    }
}
