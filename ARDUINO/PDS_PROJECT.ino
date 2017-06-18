int mtr1 = 13;
int mtr2 = 12;

void setup() 
{
  pinMode(mtr1, OUTPUT);
  pinMode(mtr2, OUTPUT);
  Serial.begin(9600);
  digitalWrite(mtr1, LOW);
  digitalWrite(mtr2, HIGH);
  delay(100);
  digitalWrite(mtr1, LOW);
  digitalWrite(mtr2, LOW);
}

void loop() 
{
  if(Serial.available() > 0)
  {
    char input = (char)Serial.read();

    if(input == 'a')
    {
      toggleDick();
    }
    else if(input == 'b')
    {
      //digitalWrite(13, LOW);
    }
  }
  delay(50);
}

void toggleDick()
{
  digitalWrite(mtr1, HIGH);
  digitalWrite(mtr2, LOW);
  delay(85);
  digitalWrite(mtr1, LOW);
  digitalWrite(mtr2, HIGH);
  delay(85);
  digitalWrite(mtr1, LOW);
  digitalWrite(mtr2, LOW);
  delay(75);
}

