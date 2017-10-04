function hopperUp
port='COM20';
channel=0;
servo_setting=6000;
device=12;

movePololuServo(port, channel, servo_setting, device);

%movePololuServo('COM3', 10, 6220, 12);
end