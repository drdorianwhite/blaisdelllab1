function Autoshaping() %NOTE:!! you need to change the results files to be whatever you need and fill in the make stim if you want varable colors as I was not sure how many/ what reward rates for each. 
%you can make many colors all with same reward or with different ones and
%that reward can be at the end of the trial or per peck based on the
%toggles at the top. 


global Session;
global Trial;
Session.codeUsed='Autoshaping'; %name of the code used for this session

Session.ITI=3; %Length of ITI
Session.stimTime=30; %Length of time (in secs) that the stim is on the screen
Session.totalTrialNumber=100; %total number of trials
Session.sessionLength=60*60; %session length determined by number of each trial type??
Session.expName='Autoshaping'; %Name of the experiment
Trial.curTrial=0; %Current trial, start at 1 or 0. make sure you know which for analysis
Session.hopperTime=3;
Session.ColorRule=1;%0=single color default white. 1=varable
Session.autoReward=0;%automaticly reward at end of trial
Session.stimSizeVar=1;%0=always the same, 1= changes by trial
Session.shape=1;%0=circle 1 = square
Session.location=0;%0=same 1= change by trial
Session.rewardInTrial=1;%1=pecks are rewarded whiel stim up. 0= only at end.
Session.stimSize=30;%stim size base
Session.rewardRate=4; %this is useful but weird. the N is the denominator 2 =1/2 4=1/4...
Trial.rule=' '; 

InitilizeSession(); %gets needed info for THIS study and this bird
RunTrial();
EndBird() %What ends the session/ closes file.


end

function GetBirdData() %Name of the function that gets data about the bird
global Session; %making this variable visible to this bit of code
prompt={'Computer#'; 'BirdName';'Level'; 'Session Number'}; %What you have to enter before the session starts
def={'1-8';'9999';'99';'99'}; %The defaults
title='Input Variables'; %Name of the prompt
lineNo=1; %Which line it should go on
userinput=inputdlg(prompt,title,lineNo,def); %Creates a prompt and the information entered goes into a cell array
Session.computerNumber=userinput{1};
Session.birdName=userinput{2};
Session.level=userinput{3};
Session.sessionNum=userinput{4};


end
function InitilizeSession() %Function that starts the session
rng;
global Session;
global Window; % NOTE TO MARY we use the same start stim for all which is set here.
GetBirdData(); % the prompt that asks for bird/session information and writes it into a cell array
Priority(1); %Makes running the code the main focus of the computer

Screen('Preference', 'ConserveVRAM', 64);
Screen('Preference', 'SkipSyncTests', 1);

Session.startSessionTime=GetSecs(); %Gets the start time of the session used for all 0. MAKE SURE SYNC WITH NEURO, for how look in howto under sync tabs
Window.screenNumber = max(Screen('Screens')); %Tells the code which screen to use
Window.backgroundColor = [0 0 0]; %sets the background color to gray


[Window.window, Window.windowRect] = PsychImaging('OpenWindow', Window.screenNumber, Window.backgroundColor); %Cmake initial screen look
[Window.xCenter, Window.yCenter] = RectCenter(Window.windowRect); %specifies what the center of the screen is
%


HideCursor(); %This will hide the cursor
MakeDataFile(); %Calls the function that will make the data file


if strcmp(Session.computerNumber,'1');
    Session.hopperUp=6220;
    Session.hopperDown=1220;
    Session.port='COM4';
    Session.channel=0;
    Session.servo_setting=1220;
    Session.device=12;
end
    if strcmp(Session.computerNumber,'6');
        Session.hopperUp=3500;
        Session.hopperDown=5000;
        Session.port='COM20';
        Session.channel=0;
        Session.servo_setting=4220;
        Session.device=12;
end
if strcmp(Session.computerNumber,'8');
    Session.hopperUp=7020;
    Session.hopperDown=4520;
    Session.port='COM4';
    Session.channel=0;
    Session.servo_setting=4220;
    Session.device=12;
end




end
function MakeDataFile() %Function that makes the data file
global Session;
cd('C:\Users\Admin\Desktop\temp\JULIA\Data');
Session.filenamePeck=strcat(Session.birdName, '-', Session.sessionNum, '-Peck', '.xls');%names the file, write file
Session.peckFid= fopen(Session.filenamePeck,'w'); %opens file, w gives permisions

fprintf(Session.peckFid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t\n',...Make header data types. redo for new data
    'Bird','Session number','Date','Time','Level','TrialNum','Rule','TrialType','SessionTime','StimTime','TrialPart','PeckNumber','PeckForThisStimNumber','ImageShown','PeckX','PeckY','PeckLocation','Correct?','Rewarded','CodeRun');


Session.filenameTrial=strcat(Session.birdName, '-', Session.sessionNum, '-Trial', '.xls');%names the file, write file
Session.trialFid= fopen(Session.filenameTrial,'w'); %opens file, w gives permisions

fprintf(Session.trialFid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t\n',...Make header data types. redo for new data
    'Bird','Session number','Date','Time','Level','TrialNum','Rule','TrialType','sessionTime','ITI','ReadyStimTrialTimeOn','TrialStimTotalSecs','ImageShown','ITIPecks','PecksToStartStim','PecksonStartScreenTotal','TotalPecksOnExStim','PecksOnExScreen','%OnStim','1Go/0NoGo','Reward#','CodeRun');
end

function RunTrial() %Function that runs the trials
global Trial;
global Session;
while (Trial.curTrial<Session.totalTrialNumber) &&((GetSecs()-Session.startSessionTime)<Session.sessionLength) %run this code when the current trial is less than the total number of trials +1
    
    ResetTrial();
    ITI(); %runs ITI
    ShowStim(); %Shows ready stim
    if Session.autoReward==1
        Reward();
    end
    if Session.rewardInTrial==0
        if rnd()< Trial.rewardRate
            Reward();
        end
    end
    RecordTrial(); %records the trial information
end %ends the while loop
end %ends the function
function ShowStim() %function that draws ready stim to screen and makes it respond to pecks
global Window;
global Session;
global Trial;
global Peck;

Trial.trialStimOnsetTime=GetSecs(); %times when the stimulus comes on screen
%(let all math be at writiing. see manual if comented means we present
%ready stim UNCOMENT for no stim
Trial.trialPart='Stim'; %specifies that this trial part is showing the start stimulus. for binning/catagorizing
Trial.peckStimNum=0; %sets peck number to zero, so it re-zeros everytime the start stim is shown

MakeStim();

Trial.readyStimOnsetTime=Screen('Flip', Window.window); %'flips' the start stim on the screen AND activates get secs, labeled as stimOnsetTime
Trial.stimOnsetTime=Trial.readyStimOnsetTime;
Peck.whereStim=Window.stimLocation;
[x,y,Trial.buttonnow] = GetMouse(); %gets the coordiate information from the mouse that is currently active. normaly the touch screen. debug screen first if error
Trial.buttonLast= Trial.buttonnow; %at start make sure we do not record a release as a press. ALWAYS for birds
while(GetSecs()-Trial.stimOnsetTime<Session.stimTime) %keep stim up for aloted time 
    
    GetPeck(); %counts the number of pecks, where, the data. DO NOT MESS WITH WITHOUT JULIA
    
end %ends the while loop

end
function MakeStim()
global Session;
global Trial;
global Window;

if Session.ColorRule==0
    Window.Color=[250 0 0];
    Trial.color='red';
    Trial.rewardRate=Session.rewardRate; %How often the bird is rewarded curently all the same 
else
    colorrand=rand();%makes different colors
    if(colorrand<.25)% make colors, name them and set color based reward rate here
        Window.Color=[250 250 250];
        Trial.color='white';
        Trial.rewardRate=Session.rewardRate;
    elseif (colorrand<.5)
        Window.Color=[0 250 250];
        Trial.color='cyan';
        Trial.rewardRate=Session.rewardRate;
    elseif (colorrand<.75)
        Window.Color=[250 250 0];
        Trial.color='yellow';
        Trial.rewardRate=Session.rewardRate;
    else
    end
end

if Session.stimSizeVar==0
   stimx=Session.stimSize;
   stimy=Session.stimSize;
else
    sizeAjust=rand();%makes different sizes up to 2x orignnal size
    stimx=Session.stimSize*(1+sizeAjust);
    stimy=Session.stimSize*(1+sizeAjust);
end

Window.baseRect = [0 0 stimx stimy]; %sets the intial dimensions of the shape

if Session.location==0

Window.stimLocation=CenterRectOnPointd(Window.baseRect,Window.xCenter, ((Window.yCenter/3)*4)); %says where to put the stim (center rect ON POINT whatever, d is arbitrary
else
   xrand=rnd();
   yrand=rnd();

   Trial.xCenter=(Window.xCenter*2)*xrand;
   Trial.yCenter=(Window.yCenter/3)*4*yrand;
   
   Window.stimLocation=CenterRectOnPointd(Window.baseRect,Trial.xCenter, Trial.yCenter);
end

if Session.shape==0
    Screen('FillOval', Window.window, Window.Color, Window.stimLocation); %draws the start stimulus and specifies where it goes, the color and location. All of these have been defined earlier
else
    Screen('FillRect', Window.window, Window.Color, Window.stimLocation);

end
end

function ITI() %fucntion for the inter-trial interval
global Trial;
global Session;
global Peck;
global Window;

Screen('FillRect', Window.window ,Window.backgroundColor)
Trial.ITIOnsetTime=Screen('Flip',Window.window); %sets the onset time
Trial.stimOnsetTime=Trial.ITIOnsetTime;
Trial.trialPart='ITI'; %specifies that the trial part is the ITI

Trial.peckStimNum=0; %sets the peck number to zero. for catigorizing by display
%specifies that this trial type has no stim associated with it, just a blank screen
Peck.whereStim=[0 0 0 0];
[x,y,Trial.buttonnow] = GetMouse(); %gets mouse button (touchscreen)
Trial.buttonLast= Trial.buttonnow; %makes button now equal to button last. no double dipping before onset
while(GetSecs()-Trial.ITIOnsetTime<Session.ITI) %says that while the seconds of THIS trial part (specified by stimOnsetTime) is less than the session ITI
    
    GetPeck(); %counts pecks/get data
end %ends the while loop


Trial.imageName=' '; %calls the image name nothiing for data file. Make sure not to say they peck the image after it is removed.
end
function GetPeck() %function for the get peck information
global Trial; %makes trial visible
global Peck; %makes peck visible
[x,y,Trial.buttonnow] = GetMouse(); %Get mouse information and labels it as button now
Peck.rewarded='0';
Peck.correct='0';

if Trial.buttonLast== Trial.buttonnow; %starts the if loop, if button last is equal to button now
    WaitSecs(.01); %then the program should wait this number of seconds
else %if button now does not equal button last
    Trial.buttonLast= Trial.buttonnow; %then wait until it does?? I'm not sure
    if ~any(Trial.buttonnow); %starts another if loop based on any button
        Trial.peckNum=Trial.peckNum+1; %sets the peck number equal to the previous peck number +1, counts the pecks
        [Peck.peckX,Peck.peckY,Bar]=GetMouse; %gets mouse coordinates, x coordinate = peck x; y coordinate = peck y; bar is a filler variable
        Peck.peckTime=GetSecs(); %starts counting the seconds for this part as peckTime
        Trial.peckStimNum=Trial.peckStimNum+1;
        WherePeck(); %calls function wherePeck, keeps track of where the pecks are
    end %ends the inner if loop
end %ends the outer if loop
end %ends the function
function WherePeck() %function that specifies where the peck is
global Peck; %makes peck visible
global Trial;

if(IsInRect(Peck.peckX,Peck.peckY,Peck.whereStim)==0);
    Peck.locationName='Screen'; %makes the peck location name equal to screen? reset through if's for location types by trial part.
    Peck.correct='0';
    if (strcmp(Trial.trialPart,'ITI'));
        Trial.ITIPeckNum=Trial.ITIPeckNum+1;
    elseif (strcmp(Trial.trialPart,'Stim'));
        Trial.trialStimScreenPeckNum=Trial.trialStimScreenPeckNum+1;
    end
else
    Peck.locationName='Stim';
    if(strcmp(Trial.trialPart,'Stim'));
        Trial.trialStimPeckNum=Trial.trialStimPeckNum+1;
            CorrectPeck();
    end
end

RecordPeck(); %calls the function to record the peck
end
function CorrectPeck() %function that specifies what a correct peck
global Peck; %makes peck visible
global Session;
global Trial;

Peck.correct='1'; %sets a correct peck equal to 1, not literally, more like a true false statement
if (Trial.trialStimPeckNum==1)
    Peck.eatNow=1;
    Peck.peckSinceReward=1;
end

if(Trial.trialStimPeckNum==1)||((Peck.eatNow>length(Peck.peckTill)))
    if(Trial.rewardRate==1)
        Peck.peckTill=1;
        Reward();
    else
   Peck.peckTill=randperm(Trial.rewardRate);
    end
    Peck.eatNow=1;
end

    if Peck.peckSinceReward==Peck.peckTill(Peck.eatNow);
        Reward(); %calls the reward function
        Peck.eatNow=Peck.eatNow+1;
       Peck.peckSinceReward=0;
    else
        Peck.peckSinceReward=Peck.peckSinceReward+1;
    end
end
function Reward() %function that explains what a reward is
global Peck; %makes peck visible
global Trial;
global Session;
Peck.rewarded='1'; %sets peck rewarded equal to 0, again not literally, more like a true false?? More when we can talk to servo hopper
Trial.rewardNum=Trial.rewardNum+1;


servo_setting=Session.hopperUp;
movePololuServo(Session.port, Session.channel, servo_setting, Session.device);
movePololuServo(Session.port, 10, 6400, Session.device);
WaitSecs(Session.hopperTime);
servo_setting=Session.hopperDown;
movePololuServo(Session.port, Session.channel, servo_setting, Session.device);
movePololuServo(Session.port, 10, 5600, Session.device);
end

function RecordPeck() %records the number of pecks, fprintf is what is doing the recording??
global Session; %
global Trial; %
global Peck; %
time=clock;%get time for trial. NOT FOR MATH only for Aaron and to check time of day in case it gets off schedual
time=[num2str(time(4)) ':' num2str(time(5))]; %makes time readable
fprintf(Session.peckFid,'%s\t',Session.birdName);      % Subject ID
fprintf(Session.peckFid,'%s\t',Session.sessionNum); %which testing time
fprintf(Session.peckFid,'%s\t',date); %the date
fprintf(Session.peckFid,'%s\t',time); %the clock time
fprintf(Session.peckFid,'%s\t',Session.level);  % reward rate/what is sued to advance
fprintf(Session.peckFid,'%d\t',Trial.curTrial);  % trial
fprintf(Session.peckFid,'%s\t',Trial.rule); %says what rule
fprintf(Session.peckFid,'%s\t',Trial.type); %says what type of trial
fprintf(Session.peckFid,'%d\t',Peck.peckTime-Session.startSessionTime); %session time
fprintf(Session.peckFid,'%d\t',Peck.peckTime-Trial.stimOnsetTime); %Peck time based when stim went up
fprintf(Session.peckFid,'%s\t',Trial.trialPart); %records what trial type
fprintf(Session.peckFid,'%d\t',Trial.peckNum); %records the TOTAL number of pecks to STIM
fprintf(Session.peckFid,'%d\t',Trial.peckStimNum);
fprintf(Session.peckFid,'%s\t',Trial.imageName); %records the image name
fprintf(Session.peckFid,'%d\t',Peck.peckX); %records the x coordinate of the peck
fprintf(Session.peckFid,'%d\t',Peck.peckY); %records the y coordinate of the peck
fprintf(Session.peckFid,'%s\t',Peck.locationName); %records the location name, this will later be screen, stimulustype,ready screen?
fprintf(Session.peckFid,'%s\t',Peck.correct); %records if the peck is correct or not. ruel set under function
fprintf(Session.peckFid,'%s\t',Peck.rewarded); %records if the peck is rewarded or not
fprintf(Session.peckFid,'%s\t\n',Session.codeUsed); %records what code was used during this trial
end
function RecordTrial() %this will record the more general trial information, how many pecks total, how many correct/incorrect trials total, etc
global Session;
global Trial;


time=clock;%get time for trial. NOT FOR MATH only for Aaron and to check time of day in case it gets off schedual
time=[num2str(time(4)) ':' num2str(time(5))]; %makes time readable

fprintf(Session.trialFid,'%s\t',Session.birdName);      % Subject ID
fprintf(Session.trialFid,'%s\t',Session.sessionNum); %which testing time
fprintf(Session.trialFid,'%s\t',date); %the date
fprintf(Session.trialFid,'%s\t',time); %the clock time
fprintf(Session.trialFid,'%s\t',Session.level);  % reward rate/what is sued to advance
fprintf(Session.trialFid,'%d\t',Trial.curTrial);  % trial
fprintf(Session.trialFid,'%s\t',Trial.rule); %says what rule
fprintf(Session.trialFid,'%s\t',Trial.type); %says what type of trial
fprintf(Session.trialFid,'%d\t',Trial.readyStimOnsetTime-Session.startSessionTime); %session time
fprintf(Session.trialFid,'%d\t',Trial.readyStimOnsetTime-Trial.ITIOnsetTime); %real ITI
fprintf(Session.trialFid,'%d\t',Trial.stimOnsetTime-Trial.readyStimOnsetTime); %readyStimTimeOn
fprintf(Session.trialFid,'%d\t',Trial.trialStimOffsetTime-Trial.stimOnsetTime);%TrialTImeReal
fprintf(Session.trialFid,'%s\t',Trial.imageName);%image shown
fprintf(Session.trialFid,'%d\t',Trial.ITIPeckNum);%Pecks in ITI
fprintf(Session.trialFid,'%d\t',Trial.startStimPeckNum);%pecks on stim%Pecks to start stim
fprintf(Session.trialFid,'%d\t',Trial.startScreenPeckNum);%pecks on stim
fprintf(Session.trialFid,'%d\t',Trial.trialStimPeckNum);%pecks on stim
fprintf(Session.trialFid,'%d\t',Trial.trialStimScreenPeckNum);%pecks screen
fprintf(Session.trialFid,'%d\t',(Trial.trialStimPeckNum/(Trial.trialStimScreenPeckNum+Trial.trialStimPeckNum)));%%on image
%fprintf(Session.trialFid,'%d\t',Trial.rewardable);%go/nogo
fprintf(Session.trialFid,'%d\t',Trial.rewardNum);%rewards
fprintf(Session.trialFid,'%s\t\n',Session.codeUsed);%Code

end
function EndSession() %function that ends the experiment, should this be modifed by a kb stroke so the pigeons aren't pecking the actual screen?

fclose('all'); %closes everything
ShowCursor;
clear Screen; %clears the screen and brings it back to normal
Priority(0); %sets priorities back to normal
clear all;
end

function ResetTrial()
global Trial;
Trial.curTrial=Trial.curTrial+1;
Trial.ITIPeckNum=0;
Trial.rewardNum=0;
Trial.stimPeckNum=0;
Trial.trialStimPeckNum=0;
Trial.trialStimScreenPeckNum=0;
Trial.startStimPeckNum=0;
Trial.startScreenPeckNum=0;
Trial.peckNum=0;
Trial.type=' ';
end

function movePololuServo(port, channel, servo_setting, device)
%MOVEPOLOLUSERVO Control an attached Pololu Maestro Servo Controller
%   Given a channel (servo number), servo setting (in 1/4 micro seconds) and
%   serial port name (string), sends a command to the Pololu Servo controller.
%
%   If multiple controllers are daisy chained on the same serial line, the
%   device parameter can be used to select which device to talk to
%   (defaults to 12).
%
%   Note that valid Serial ports can sometimes be found using
%   instrfindall() (or by looking in /dev/cu.* on *nix or OSX machines)
%
%   port - The Serial Port. Note on Linux and OSX the controller will
%          create two virtual serial ports, e.g. /dev/cu.usbmodem00234567
%          and /dev/cu.usbmodem00234563 - you must select the one with a
%          lower numerical number.
%   channel - The channel of interest
%   servo_setting - The servo pulse width setting in 1/4 micro seconds
%   device - The Pololu controller device ID. Defaults to 12
%
%   Example usage:
%   Linux/OSX: movePololuServo('/dev/cu.usbmodem00234567', 0, 6120);
%   Windows: movePololuServo('\\.\COM6', 0, 6120);
%   Using a SpringRC Continuous Rotation Servo, a setting of 6120 corresponds
%   to about 2RPM, while 6000 is 0. Anything below 6000 runs the servo in
%   reverse.
%
%   note that before using this script, the controller must be
%   modified using the Pololu Servo Controller Software to be in USB Dual
%   Port mode.
%
%   This code based on discussions at
%   http://forum.pololu.com/viewtopic.php?f=16&t=3246

% Device number is 12 by default
if(nargin == 3)
    device = 12;
end

% Initialize
ser1 = serial(port);
%set(ser1, 'InputBufferSize', 2048);
%set(ser1, 'BaudRate', 9600);
%set(ser1, 'DataBits', 8);
%set(ser1, 'Parity', 'none');
%set(ser1, 'StopBits', 1);
fopen(ser1);

% Format servo command
lower = bin2dec(regexprep(mat2str(fliplr(bitget(6120, 1:7))), '[^\w'']', ''));
upper = bin2dec(regexprep(mat2str(fliplr(bitget(servo_setting, 8:14))), '[^\w'']', ''));


command = [170, device, 4, channel, lower, upper];

% Simple Serial Protocol
% 0x84 = 132
%command = [132, channel, lower, upper];

% Send the command
fwrite(ser1, command);

% Clean up - NB: On some Mac MATLAB versions, fclose will crash MATLAB
% If so, you'll need to modify this function to pass in a serial
% instance, and then never close the port in your own code
fclose(ser1);
delete(ser1);
end
function EndBird()
global Window;
Screen('FillRect', Window.window ,Window.backgroundColor) %fills the background color to be gray
Screen('Flip',Window.window);


while(1)
    [keyIsDown,secs,keyCode]=KbCheck;%#ok
    if keyIsDown
        key2=find(keyCode);
        keyPressed=KbName(key2);
        if iscell(keyPressed), keyPressed=cell2mat(keyPressed); end
        responceKey=keyPressed(1);
        if strcmp(responceKey,'q')
            break;
        end
    end
end
EndSession();%quite if they asked to

end


