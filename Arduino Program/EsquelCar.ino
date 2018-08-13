int Left_motor=8;     
int Left_motor_pwm=9;
int Right_motor_pwm=10;    
int Right_motor=11;    

void setup()
{
  Serial.begin(9600);
  pinMode(Left_motor,OUTPUT); 
  pinMode(Left_motor_pwm,OUTPUT); 
  pinMode(Right_motor_pwm,OUTPUT);
  pinMode(Right_motor,OUTPUT);
}

void brake()
{
  
  digitalWrite(Right_motor_pwm,LOW);      
  analogWrite(Right_motor_pwm,0);

  digitalWrite(Left_motor_pwm,LOW);  
  analogWrite(Left_motor_pwm,0); 
}


void loop()
{
   if (Serial.available()){
      byte x = Serial.read();

      if (x & 1){
        digitalWrite(Left_motor,LOW);
      }else{
        digitalWrite(Left_motor,HIGH);
      }

      if (x & 2){
        digitalWrite(Left_motor_pwm,HIGH);
        analogWrite(Left_motor_pwm,150);
      }else{
        digitalWrite(Left_motor_pwm,LOW);
        analogWrite(Left_motor_pwm,0);
      }

      if (x & 4){
        digitalWrite(Right_motor,LOW);
      }else{
        digitalWrite(Right_motor,HIGH);
      }

      if (x & 8){
        digitalWrite(Right_motor_pwm,HIGH);   
        analogWrite(Right_motor_pwm,150);
      }else{
        digitalWrite(Right_motor_pwm,LOW);   
        analogWrite(Right_motor_pwm,0);
      }

      if (x & 16){
        brake();
      }
   }
}
