% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if avaliable
screenNumber = max(screens);

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;
inc = white - grey;

% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Get the maximum coded luminance level (this should be 1)
maxLum = Screen('ColorRange', window);
topPriorityLevel = MaxPriority(window);

boarder = 20;
randperm(6,1);
dir = 'C:\Users\meflaim\Documents\Stuff for Blaisdell\P104\RpmStimuli\HorizontalIncorrectMajor\';
cd(dir);
ImagesToUse = ls('*.jpg');
FirstImageShown = imread([dir ImagesToUse(1,:)]);
FirstImageShownText = Screen('MakeTexture', window, FirstImageShown);
Size1 = size(FirstImageShown)

Screen('DrawTexture', window, FirstImageShownText, [], [], 0);
Screen('Flip', window);
WaitSecs(2);
sca;


