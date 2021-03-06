   function P019A()
global Session;
global Trial;
Session.codeUsed='P019A Vert'; %name of the code used for this session

Session.ITI=3; %Length of ITI
Session.stimTime=30; %Length of time (in secs) that the stim is on the screen
Session.startStimPecks=1; %How many pecks are needed to advance ready stim
Session.minPecksToReward=5; %How often the bird is rewarded
Session.maxPecksToReward=15;
Session.totalTrialNumber=100; %total number of trials
Session.sessionLength=60*60; %sessionq length determined by number of each trial type??
Session.trialTypes=2; %The trial types, correqct or incorrect, for multiple of each add then subdevide withini trial function.
Session.expName='P019A Vert'; %Name of the experiment
Trial.rule='Vert'; %Rule shown if changees by day read in under getbirddata
Trial.imageName=' '; %Name of the image, taken from directory. start with blank IF you write image at all timepoints. Otherwise no worries
Trial.curTrial=0; %Current trial, start at 1 or 0. make sure you know which for analysis
Session.hopperTime=3;

InitilizeSession(); %gets needed info for THIS study and this bird
RunTrial();
EndBird(); %What ends the session/ closes file.


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
    %Session.probe=userinput{5};
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
    Window.startColor = [255 255 255]; %sets the ready stim color to red
    Window.baseRect = [0 0 30 35]; %sets the intial dimensions of the circle

    [Window.window, Window.windowRect] = PsychImaging('OpenWindow', Window.screenNumber, Window.backgroundColor); %Cmake initial screen look
    [Window.xCenter, Window.yCenter] = RectCenter(Window.windowRect); %specifies what the center of the screen is
    Window.stimLocation=CenterRectOnPointd(Window.baseRect,Window.xCenter, ((Window.yCenter/3)*4)); %says where to put the stim (center rect ON POINT whatever, d is arbitrary
    %


    HideCursor(); %This will hide the cursor
    MakeDataFile(); %Calls the function that will make the data file
    MakeTrialList(); %function that makes the list of trials

    if strcmp(Session.computerNumber,'1');
        Session.hopperUp=6220;
        Session.hopperDown=1220;
        Session.port='COM4';
        Session.channel=0;
        Session.servo_setting=1220;
        Session.device=12;
    end
    if strcmp(Session.computerNumber,'6');
        Session.hopperUp=7500;
        Session.hopperDown=6220;
        Session.port='COM15';
        Session.channel=0;
        Session.servo_setting=4220;
        Session.device=12;
    end
    if strcmp(Session.computerNumber,'8');
        Session.hopperUp=4100;
        Session.hopperDown=6000;
        Session.port='COM16';
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
function MakeTrialList() %Function that makes the trial list/counterbalance
    global Session;
    Session.trialList=zeros(Session.totalTrialNumber,2); %frame for storing
    Session.trialList(:,2)=randperm(Session.totalTrialNumber); %order randomizing used for balancing trial type
    Session.trialList(Session.trialList(:,2)<=(Session.totalTrialNumber/Session.trialTypes),1)=1; %For half correct makes half 1
    Session.trialList(Session.trialList(:,2)<=(Session.totalTrialNumber/(Session.trialTypes*2)),1)=2; %Making half of the remaining half equal to 2 (type 1 of incorrect)
    Session.trialList=Session.trialList(:,1);

end
function RunTrial() %Function that runs the trials
    global Trial;
    global Session;
    while (Trial.curTrial<Session.totalTrialNumber) &&((GetSecs()-Session.startSessionTime)<Session.sessionLength) %run this code when the current trial is less than the total number of trials +1

        ResetTrial();
        ITI(); %runs ITI
        ReadyStim(); %Shows ready stim
        RunStim(); %shows training stimulus

        RecordTrial(); %records the trial information
    end %ends the while loop
end %ends the function
function ReadyStim() %function that draws ready stim to screen and makes it respond to pecks
    global Window;
    global Session;
    global Trial;
    global Peck;

    %Trial.stimOnsetTime=GetSecs(); %times when the stimulus comes on screen
    %(let all math be at writiing. see manual if comented means we present
    %ready stim UNCOMENT for no stim
    Trial.trialPart='StartStim'; %specifies that this trial part is showing the start stimulus. for binning/catagorizing
    Trial.peckStimNum=0; %sets peck number to zero, so it re-zeros everytime the start stim is shown

    Screen('FillOval', Window.window, Window.startColor, Window.stimLocation); %draws the start stimulus and specifies where it goes, the color and location. All of these have been defined earlier
    Trial.readyStimOnsetTime=Screen('Flip', Window.window); %'flips' the start stim on the screen AND activates get secs, labeled as stimOnsetTime
    Trial.stimOnsetTime=Trial.readyStimOnsetTime;
    Peck.whereStim=Window.stimLocation;
    [x,y,Trial.buttonnow] = GetMouse(); %gets the coordiate information from the mouse that is currently active. normaly the touch screen. debug screen first if error
    Trial.buttonLast= Trial.buttonnow; %at start make sure we do not record a release as a press. ALWAYS for birds
    while(Trial.startStimPeckNum<Session.startStimPecks) %make sure to swap between peck requirement and time

        GetPeck(); %counts the number of pecks, where, the data. DO NOT MESS WITH WITHOUT JULIA

    end %ends the while loop

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
        elseif(strcmp(Trial.trialPart,'StartStim'));
            Trial.startScreenPeckNum=Trial.startScreenPeckNum+1;
        elseif (strcmp(Trial.trialPart,'StimUp'));
            Trial.trialStimScreenPeckNum=Trial.trialStimScreenPeckNum+1;
        end
    else
        Peck.locationName='Stim';
        if(strcmp(Trial.trialPart,'StartStim'));
            Trial.startStimPeckNum=Trial.startStimPeckNum+1;
        elseif(strcmp(Trial.trialPart,'StimUp'));
            Trial.trialStimPeckNum=Trial.trialStimPeckNum+1;
            if (Trial.rewardable==1)
                CorrectPeck();
            elseif (Trial.rewardable==0)
                Peck.correct='0';
            end
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
        if((Session.maxPecksToReward-Session.minPecksToReward)==0);
            Peck.peckTill=Session.minPecksToReward;
        else
            Peck.peckTill=randperm(Session.maxPecksToReward-Session.minPecksToReward);
            Peck.peckTill=Peck.peckTill+Session.minPecksToReward;
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
function RunStim() %function that runs the training stim
    global Trial;
    global Session; %makes session visible
    global Window; %makes window visible
    global Peck;
    if Session.trialList(Trial.curTrial) == 0; %see session setup
        dir = 'C:\Users\Admin\Desktop\JULIA\Vert\trainingVerticalStim\'; %then use this directory, which will only draw correct stim
        Trial.type='V Correct'; %specifies  the trial type
        Trial.rewardable=1;
    elseif Session.trialList(Trial.curTrial) == 1;
        dir = 'C:\Users\Admin\Desktop\JULIA\Vert\VerticalIncorrectMajor\'; %then use this directory, which only draw major rule violations
        Trial.type='V Major'; %labels this trial type
        Trial.rewardable=0;
    else
        dir = 'C:\Users\Admin\Desktop\JULIA\Vert\VerticalIncorrectMinor\'; %makes the other option in the 1 if loop this directory
        Trial.type='V Minor';
        Trial.rewardable=0;
    end %ends the if loop

    cd(dir); %Puts the directory on the current path
    ImagesToUse = ls('*.jpg'); %specifies that the images to use is the list of names that end with .jpg
    imagevec = randperm(length(ImagesToUse), 1); %creates an image vector thats a random permutation of the list of images to use
    image= {ImagesToUse(imagevec, :)}; %image is a cell name generated by the ImagesToUse by the imagevec
    Trial.imageName=image{1}; %puts the image name in
    stim = imread([dir ImagesToUse(imagevec,:)]); %the stim is equal to the images should read from the directory called by the ImagesToUse(imagevec
    t = Screen('MakeTexture', Window.window, stim); %modifies the jpg so it looks normal on the screen
    [Peck.imageLocY,Peck.imageLocX,~]=size(stim);
    Peck.whereStim=CenterRectOnPointd([0 0 Peck.imageLocX Peck.imageLocY],Window.xCenter,((Window.yCenter/3)*4));
    Window.exStimLocation=Peck.whereStim;
    Screen('DrawTexture', Window.window, t, [], Window.exStimLocation); %still about making the image normal and getting it on the screen

    Screen('Flip',Window.window); %puts the stim on the screen
    Trial.peckStimNum=0;



    Trial.trialStimOnsetTime=GetSecs();
    Trial.stimOnsetTime=Trial.trialStimOnsetTime;
    Trial.trialPart='StimUp'; %specifies that this part of the trial is that the stim has gone up
    Trial.peckStimNum=0; %sets pecknumber to 0 and does this everytime the stim goes up
    [x,y,Trial.buttonnow] = GetMouse(); %get mouse coordinates
    Trial.buttonLast= Trial.buttonnow; %sets the current button to the last button
    while(GetSecs()-Trial.stimOnsetTime<Session.stimTime) %keep stim up for aloted time

        GetPeck(); %then record the number of pecks

    end %ends the while loop
    Screen('FillRect', Window.window ,Window.backgroundColor)
    Trial.trialStimOffsetTime=Screen('Flip',Window.window); %sets the onset time
end %ends function
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
    fprintf(Session.trialFid,'%d\t',Trial.trialStimOnsetTime-Trial.readyStimOnsetTime); %readyStimTimeOn
    fprintf(Session.trialFid,'%d\t',Trial.trialStimOffsetTime-Trial.trialStimOnsetTime);%TrialTImeReal
    fprintf(Session.trialFid,'%s\t',Trial.imageName);%image shown
    fprintf(Session.trialFid,'%d\t',Trial.ITIPeckNum);%Pecks in ITI
    fprintf(Session.trialFid,'%d\t',Trial.startStimPeckNum);%pecks on stim%Pecks to start stim
    fprintf(Session.trialFid,'%d\t',Trial.startScreenPeckNum);%pecks on stim
    fprintf(Session.trialFid,'%d\t',Trial.trialStimPeckNum);%pecks on stim
    fprintf(Session.trialFid,'%d\t',Trial.trialStimScreenPeckNum);%pecks screen
    fprintf(Session.trialFid,'%d\t',(Trial.trialStimPeckNum/(Trial.trialStimScreenPeckNum+Trial.trialStimPeckNum)));%%on image
    fprintf(Session.trialFid,'%d\t',Trial.rewardable);%go/nogo
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
            responseKey=keyPressed(1);
            if strcmp(responseKey,'q')
                break;
            end
        end
    end
    EndSession();%quite if they asked to

end


