%CAUSAL REASONING PIGEON EXPERIMENT ROUTINE version 1
%Author: Lehel Kovach
%Date: 10-6-2017
%Description: controls flow of causal reasoning experiment and reads in
%input of pigeon behaviors for the different phases of the experiment



function causalreasoning2017v1()

    SetSessionVariableDefaults();
    PromptForSessionVariables();
    ConfigureHopperSettings();
    MakeDataFiles(); %Calls the function that will make the data file
    InitiateDisplay();
    parfeval(@RecordPecks, 0, 0);  %functions that monitor input (pecks) will run on separate thread... 
    
    if Session.phaseOfExperiment == 1
        runPhase0();
    elseif Session.phaseOfExperiment == 2
        runPhase1();
    elseif Session.phaseOfExperiment == 3
        runPhase2();
    else
        runPhase3();
    end

    EndSession();
end


function SetSessionVariableDefaults()
    global Session;
    
    Session.screenPeckNumber = 0;
    Session.keyPeckNumber = 0;
    Session.intervalNumber = 1;
    Session.keyDown = 0;
    Session.keyCode = 10; %figure out what key code should be!
    Session.running = 1;
    Session.keyPecked = 0;  
end


function PromptForSessionVariables()
    global Session;
    
    title='Enter Input Variables';
    prompt={'Computer#'; 'BirdName';'Day#'; 'Phase#'}; %What you have to enter before the session starts
    userinput=inputdlg(prompt,title);
    Session.computerNumber = userinput{1};
    Session.pigeonName = userinput{2};
    Session.dayOfExperiment = userinput{3};
    Session.phaseOfExperiment = userinput{4};
    
    if Session.phaseOfExperiment == 1
        title='Enter Training Phase Variables';
        prompt={'Max Minutes'; 'Max Intervals';'Max Key On Secs'; 'Raise Hopper Secs'}; 
        lineNo=1;
        defaultVals={'30';'12';'120';'5'};
        userinput=inputdlg(prompt,title, lineNo, defaultVals);
        
        Session.maxMinutesForPhase0 = STR2DOUBLE(userinput{1});
        Session.maxKeyOnIntervalsPhase0 = STR2DOUBLE(userinput{2});
        Session.maxKeyOnSecondsPhase0 = STR2DOUBLE(userinput{3});
        Session.hopperRaisedSecondsPhase0 = STR2DOUBLE(userinput{4});
    end
    
    if Session.phaseOfExperiment == 2
        title='Enter Phase 1 Variables';
        prompt={'Median ITI Minutes'; 'ITI max variance Minutes';'#Trials'; 'Stim Color'; 'Stim On Secs'; 'Secs between Stims'}; 
        lineNo=1;
        defaultVals={'5';'2';'12';'Green';'5';'2'};
        userinput=inputdlg(prompt,title, lineNo, defaultVals);
        
        Session.phase1ITIMedianMinutes = STR2DOUBLE(userinput{1});
        Session.phase1ITIVarianceMinutes = STR2DOUBLE(userinput{2});
        Session.phase1NumTrials = STR2DOUBLE(userinput{3});
        Session.phase1StimColor = userinput{4};
        Session.phase1StimOnSeconds = STR2DOUBLE(userinput{5});
        Session.phase1NumTrials = STR2DOUBLE(userinput{6});
    end
    
    
    if SessionPhaseOfExperiment == 3
        title='Enter Phase 2 Variables';
        prompt={'Median ITI Minutes'; 'ITI max variance Minutes';'#Trials'; 'Stim On Secs'; 'Secs between Stims'}; 
        lineNo=1;
        defaultVals={'5';'2';'12';'5';'2'};
        userinput=inputdlg(prompt,title, lineNo, defaultVals);
        
        Session.phase2ITIMedianMinutes = STR2DOUBLE(userinput{1});
        Session.phase2ITIVarianceMinuts = STR2DOUBLE(userinput{2});
        Session.phase2NumTrials = STR2DOUBLE(userinput{3});
        Session.phase2KeyOnSeconds = userinput{4};
        Session.phase2HopperDownSeconds = STR2DOUBLE(userinput{5});
    end
        
    
    if SessionPhaseOfExperiment == 4
        title='Enter Test Phase Variables';
        prompt={'0=Observ/1=Interv'; 'Observ #Presentations';'Median ITI Minutes'; 'ITI max variance Minutes'; 'Shape1 Color';'Shape2 Color';'Tone Secs On'}; 
        lineNo=1;
        defaultVals={'0';'6';'5';'2';'blue';'green';'10'};
        userinput=inputdlg(prompt,title, lineNo, defaultVals);
        
        Session.phase3IsInterventionType = STR2DOUBLE(userinput{1});
        Session.phase3ObservationPresentationCount = STR2DOUBLE(userinput{2});
        Session.phase3ITIMedianMinutes = STR2DOUBLE(userinput{3});
        Session.phase3ITIVarianceMinuts = userinput{4};
        Session.phase3NovelShape1Color = userinput{5};
        Session.phase3InterventionTonePresentationSeconds = userinput{6};
    end
    
end

function ConfigureHopperSettings()
    global Session;
    
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
        Session.hopperDown=6000;
        Session.port='COM20';
        Session.channel=0;
        Session.servo_setting=4220;
        Session.device=12;
    end
    if strcmp(Session.computerNumber,'8');
        Session.hopperUp=4000;
        Session.hopperDown=6100;
        Session.port='COM16';
        Session.channel=0;
        Session.servo_setting=4220;
        Session.device=12;
    end
end

function MakeDataFiles() %Function that makes the data file
    global Session;
    cd('..\Data');
    Session.filenameScreenPeck=strcat('CausalReasoning-', Session.birdName, '-', Session.dayOfExperiment, '-ScreenPeck', '.xls');%names the file, write file
    Session.screenPeckFid= fopen(Session.filenameScreenPeck,'w'); %opens file, w gives permisions

    fprintf(Session.screenPeckFid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t\n',...Make header data types. redo for new data
        'Computer','Bird','Phase', 'Day', 'Date','Time','TrialNum','TrialType','ScreenPeckNumber','PeckX','PeckY');

    Session.filenameKeyPeck=strcat('CausalReasoning-', Session.birdName, '-', Session.dayOfExperiment, '-KeyPeck', '.xls');%names the file, write file
    Session.keyPeckFid= fopen(Session.filenameKeyPeck,'w'); %opens file, w gives permisions

    fprintf(Session.keyPeckFid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t\n',...Make header data types. redo for new data
        'Computer','Bird','Phase', 'Day', 'Date','Time','TrialNum','TrialType','KeyPeckNumber');
end


function InitiateDisplay() %Function that starts the session
    %rng
    global Session;
    global Window; % NOTE TO MARY we use the same start stim for all which is set here.
    Priority(1); %Makes running the code the main focus of the computer

    Screen('Preference', 'ConserveVRAM', 64);
    Screen('Preference', 'SkipSyncTests', 1);
    Screen('Preference','VisualDebugLevel', 0);

    Session.startSessionTime=GetSecs(); %Gets the start time of the session used for all 0. MAKE SURE SYNC WITH NEURO, for how look in howto under sync tabs
    Window.screenNumber = max(Screen('Screens')); %Tells the code which screen to use
    Window.backgroundColor = [0 0 0]; %sets the background color to gray
    Window.startColor = [255 255 255]; %sets the ready stim color to red
    Window.baseRect = [0 0 30 35]; %sets the intial dimensions of the circle

    [Window.window, Window.windowRect] = PsychImaging('OpenWindow', Window.screenNumber, Window.backgroundColor); %Cmake initial screen look
    [Window.xCenter, Window.yCenter] = RectCenter(Window.windowRect); %specifies what the center of the screen is
    Window.stimLocation=CenterRectOnPointd(Window.baseRect,Window.xCenter, ((Window.yCenter/3)*4)); %says where to put the stim (center rect ON POINT whatever, d is arbitrary
 
    %HideCursor(); %This will hide the cursor
end

%controls magazine training
function runPhase0()
    global Session;
    Session.intervalNumber = 1;
    tic;
    maxSeconds = Session.maxMinutesForPhase0 * 60;
   
    
    disp('Training Phase Started...');
    
    while Session.intervalNumber < Session.maxKeyOnIntervalsPhase0  && toc < maxSeconds
        fprintf('current interval: %d', Session.intervalNumber);
        
        turnKeyOn();
        LowerHopper();
        
        keyPecked = 0;
        keyOnTime = toc;
        
        while toc - keyOnTime <  Session.maxKeyOnSecondsPhase0 || keyPecked == 0
            WaitSecs(0.1);
            if Session.keyPecked == 1
                keyPecked = Session.keyPecked;
                Session.keyPecked = 0;
                turnKeyOff();
                RaiseHopper();
                WaitSecs(5.0);
            end
        end
        
        Session.intervalNumber = Session.intervalNumber + 1;
    end
end

function runPhase1()

end

function runPhase2()

end

function runPhase3()

end

function turnKeyOn()
    %fill this in with correct code
end

function turnKeyOff()
    %fill this in with correct code
end

function RecordPecks()
    global Session;
    
    while Session.running == 1  
        GetScreenPeck();
        GetKeyPeck();
        WaitSecs(0.1);
    end
end

function GetScreenPeck() %function for the get peck information
    global Session;
    global Peck; %makes peck visible
    [x,y,Session.buttonnow] = GetMouse(); %Get mouse information and labels it as button now

    if Session.buttonLast ~= Session.buttonnow; %starts the if loop, if button last is equal to button now
        Session.buttonLast= Session.buttonnow; %then wait until it does?? I'm not sure
        
        if ~any(Session.buttonnow); %starts another if loop based on any button
            Session.screenPeckNumber = Session.screenPeckNumber+1; %sets the peck number equal to the previous peck number +1, counts the pecks
            [Peck.peckX,Peck.peckY,Bar]=GetMouse(); %gets mouse coordinates, x coordinate = peck x; y coordinate = peck y; bar is a filler variable
            Peck.peckTime=GetSecs(); %starts counting the seconds for this part as peckTime
            RecordsScreenPeck();
        end %ends the inner if loop
    end %ends the outer if loop
end %ends the function

function RecordsScreenPeck() %records the number of pecks, fprintf is what is doing the recording??
    global Session; %
    global Peck; %
    
    time=clock;%get time for trial. NOT FOR MATH only for Aaron and to check time of day in case it gets off schedual
    time=[num2str(time(4)) ':' num2str(time(5))]; %makes time readable
    fprintf(Session.screenPeckFid,'%d\t',Session.computerNumber);    
    fprintf(Session.screenPeckFid,'%s\t',Session.birdName);      % Subject ID
    fprintf(Session.screenPeckFid,'%s\t',Session.phaseOfExperiment); %which testing time
    fprintf(Session.screenPeckFid,'%s\t',Session.dayOfExperiment);
    fprintf(Session.screenPeckFid,'%s\t',date); %the date
    fprintf(Session.screenPeckFid,'%s\t',time); %the clock time
    fprintf(Session.screenPeckFid,'%d\t',Session.intervalNumber);  % trial
    if isempty(Session.phase3IsInterventionType)
        type = 0;
    else
        type = Session.phase3IsInterventionType;
    end
    fprintf(Session.screenPeckFid,'%s\t',type); %says what type of trial
    fprintf(Session.screenPeckFid,'%d\t',Session.screenPeckNumber); %session time
    fprintf(Session.screenPeckFid,'%d\t',Peck.peckX); %records the x coordinate of the peck
    fprintf(Session.screenPeckFid,'%d\t',Peck.peckY); %records the y coordinate of the peck
end

function GetKeyPeck()
    global Session;
    
    [keyIsDown,secs,keyCode]=KbCheck;%#ok
    
    if keyIsDown == 1 && keyCode(Session.keyCode) == 1 && Session.keyDown == 0
       Session.keyDown = 1;
    elseif keyIsDown == 0 && Session.keyDown == 1
        Session.keyDown = 0;
        Session.keyPecked = 1;
        RecordKeyPeck();   
    end
end

function RecordKeyPeck()
    global Session; %

    time=clock;%get time for trial. NOT FOR MATH only for Aaron and to check time of day in case it gets off schedual
    time=[num2str(time(4)) ':' num2str(time(5))]; %makes time readable
    %'Computer','Bird','Phase', 'Day', 'Date','Time','TrialNum','TrialType','KeyPeckNumber'
    fprintf(Session.screenPeckFid,'%d\t',Session.computerNumber);    
    fprintf(Session.screenPeckFid,'%s\t',Session.birdName);      % Subject ID
    fprintf(Session.screenPeckFid,'%s\t',Session.phaseOfExperiment); %which testing time
    fprintf(Session.screenPeckFid,'%s\t',Session.dayOfExperiment);
    fprintf(Session.screenPeckFid,'%s\t',date); %the date
    fprintf(Session.screenPeckFid,'%s\t',time); %the clock time
    fprintf(Session.screenPeckFid,'%d\t',Session.intervalNumber);  % trial
    if isempty(Session.phase3IsInterventionType)
        type = 0;
    else
        type = Session.phase3IsInterventionType;
    end
    fprintf(Session.screenPeckFid,'%s\t',type); %says what type of trial
    fprintf(Session.screenPeckFid,'%d\t',Session.keyPeckNumber); %session time
end



function RaiseHopper()
    global Session;    
    movePololuServo(Session.port,Session.channel,Session.hopperUp,Session.device);
end

function LowerHopper()
     global Session;    
    movePololuServo(Session.port,Session.channel,Session.hopperDown,Session.device);
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

function EndSession() %function that ends the experiment, should this be modifed by a kb stroke so the pigeons aren't pecking the actual screen?
    global Session;
    fclose('all'); %closes everything
    Session.running = 0;
    ShowCursor;
    clear Screen; %clears the screen and brings it back to normal
    Priority(0); %sets priorities back to normal
    clear all;
end

