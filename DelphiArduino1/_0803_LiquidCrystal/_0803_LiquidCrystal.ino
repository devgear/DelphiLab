#include <LiquidCrystal.h>
LiquidCrystal lcd( 7,8,9,10,11,12 );

const int ledPin = 2;      int tempPin = A0;
char cTemp;   String sCommand = "";     String sTemp = "";
 
void setup() {
  pinMode(ledPin, OUTPUT);  
  lcd.begin(16, 2);
  Serial.begin(9600);  
}

void loop() {
  int tempReading = analogRead(tempPin);
  float tempVolts = tempReading * 5.0 / 1024.0;  
  float tempC = (tempVolts - 0.5) * 100.0; 

  // 칸, 줄   
  lcd.setCursor(0, 0);    lcd.print("Temp ");
  lcd.setCursor(6, 0);    lcd.print(tempC);    lcd.print(" C");  
  
  Serial.print( tempC  );  
  // 종료문자 지정
  Serial.write( 0x13 );       // 0x5A  => Serial.write( 'Z' );   Serial.print( 'Z', HEX );  <- HEX 아스키값 알수 있음.   
  delay(500);
  
  sCommand = "";
  while(Serial.available())
   {
     cTemp = Serial.read();
     switch ( cTemp ) {
        case '0' :  digitalWrite(ledPin, LOW); break;      // LED ON/OFF
        case '1' :  digitalWrite(ledPin, HIGH); break;
     }
     sCommand.concat(cTemp);
   }
    
    if(sCommand != "" )  {   // 메시지 출력
       lcd.setCursor(0, 1);        
       lcd.print( sCommand );
   }
   delay(100);
}
