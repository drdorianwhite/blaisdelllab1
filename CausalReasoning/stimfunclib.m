% file: stim_functions.m
% author: Lehel KOvach
% date: 10/31/2017
% title: Stimuli Functions Library
% description:  contains utility functions for displaying visual shape stimuli and
% auditory tone stimuli.  these functions allow for control of location,
% color/frequency and show/hide. 
%
% The library is interfaced by the single function: stimfunclib, which takes
% specific string values representing the functions in this library (i.e.,
% 'create', 'on', 'off' and 'modify' and the second parameter being
% a matrix containing the input parameters for the function
% A stimuli that is instatiated through the functions, 'Create'  return a value that
% represents a handle to the stimulus.  to present the stimulus, call
% 'On' passing this handle as the the first parameter.  Likewise for
% stopping the presentation with 'Off'.  To change any parameters of a
% created stimulus (i.e., changing its color, position, frequency, etc,)
% call the function 'Modify' with the handle of the stimulus

function ret = stimfunclib(sfl_func_name, varargin)
   
    SFLInit();
    
    if isempty(sfl_func_name)
        error('SFL error: SFLCall not provided a function name');
    end
    
    switch sfl_func_name
        case 'create'
            ret = SFLCreate(varargin);
        case 'on'
            ret = SFLOn(varargin);
        case 'off'
            ret = SFLOff(varargin);
        case 'modify'
            ret = SFLModify(varargin);
        otherwise
            error('SFL error: function name supplied does not exist!');
    end

end

    
function SFLInit()
    global sfm_initialized;
    global sfm_stimuli;
    
    if ~exist('sfm_initialized')
        sfm_initialized =  'initialized';
        sfm_stimuli.dummy = 0;
        clear sfm_stimuli.visual;
        InitializePsychSound(1); %inidializes sound driver...the 1 pushes for low latency
    end    
end

% SFLCreate: called via stimfunclib('create', params)
% inputs: 
    % param(1): stimulus type (valid values = 'visual' and 'auditory')
    % param(2): params specific to SFLCreateVisual and SFLCreateAuditory
function ret = SFLCreate(params)

    if isempty(params{1})
        error('SFL error: SFLCreate not provided a stimulus type');
    end
    
    if params{1} == 'visual'
            ret = SFLCreateVisual(params(2:end));
    elseif params{1} ==  'auditory'
            ret = SFLCreateAuditory(params(2:end));
    else
            error('SFL error: SFLCreate given bad stimulus type');
    end
end

% create visual stimuli (colored shape at a location)
% input:
    % param(1): shape string (accepted values: 'FillRect' and 'FillOval')
    % param(2): 3 element int array containg RGB values for color of shape
    % param(3): 4 element array for rect position/size of shape   
    % params(4): rgb value of window bgcolor
function stim_handle = SFLCreateVisual(params)
    global sfm_stimuli;
    
    if isempty(params{1})
        error('error in SFLCreateVisual: no parameter supplied!');
    end
    
    if params{1} ~= 'FillRect'
        error('error in SFLCreateVisual: invalid shape function supplied!');
    end
    
    if  params{1} ~= 'FillOval'
        error('error in SFLCreateVisual: invalid shape function supplied!');
    end
    
    if ~exist('sfm_stimuli.visual')
        index = 1;
    else
        index = lenght(sfm_stimuli.visual);
    end
    
    sfm_stimuli.visual(index).handle = 0; % just allocate it for now...
    sfm_stimuli.visual(index).shape = params{1};
    sfm_stimuli.visual(index).window = params{2};
    sfm_stimuli.visual(index).shapecolor = params{3};
    sfm_stimuli.visual(index).shaperect = params{4};
    sfm_stimuli.visual(index).bgcolor = params{5};
    sfm_stimuli.visual(index).handle = length(index);
    stim_handle = index;
end


% create auditory stimuli (colored shape at a location)
% input:
    % param(1): sound type string (accepted values: 'ConstantTone' and 'ConstantNoise')
    % optional param(2): number of time to repeat playing the sound file
    % optional param(3): frequency to play sound at
function stim_handle = SFLCreateAuditory(params)
    global sfm_stimuli;
    
    if isempty(params{1})
        error('error in SFLCreateAuditory: no parameter supplied!');
    end
    
    if params{1} ~= 'ConstantTone' && params{1} ~= 'ConstantNoise'
        error('error in SFLCreateAuditory: invalid sound function supplied!');
    end
    
    if params{1} == 'ConstantTone'
        wavefile = '..\Audio\tone.wav';
    else
        wavefile = '..\Audio\noise.wave';
    end
    
    [wavedata, freq] = AUDOREAD(wavefile); % load sound file (make sure that it is in the same folder as this script
    new_stim.pahandle = PsychPortAudio('Open', [], [], 2, freq, 1, 0); % opens sound buffer at a different frequency
    PsychPortAudio('FillBuffer', new_stim.pahandle, wavedata'); % loads data into buffer
    
    if ~exist('sfm_stimuli.auditory')
        index = 1;
    else
        index = lenght(sfm_stimuli.auditory);
    end
    
    sfm_stimuli.auditory(index).handle = 0; % just allocate it for now...
    sfm_stimuli.auditory(index).sound = params{1};
    sfm_stimuli.auditory(index).repeat = params{2};
    if exist(sfm_stimuli.auditory(index).repeat, 'var') == 0
        sfm_stimuli.auditory(index).repeat = 0;
    end
    sfm_stimuli.auditory(index).handle = length(index);
    stim_handle = index;
end



function ret = SFLOn(params)
    if isempty(params{1})
        error('SFL error: SFLOn not provided a stimulus type');
    end
    
    switch params{1}
        case 'visual'
            ret = SFLVisualOn(params(2:end));
        case 'auditory'
            ret = SFLAuditoryOn(params(2:end));
        otherwise
            error('SFL error: SFLOn given bad stimulus type');
    end
    
    
end

% params(1): stim handle
% params(2): window handle
function onset = SFLVisualOn(params)
    global sfm_stimuli;
    stim_data = sfm_stimuli.visual(params{1});
    %Screen('FillRect', params{2} ,stim_data.shapecolor);
    Screen('FillRect', stim_data.window,stim_data.shapecolor, stim_data.shaperect);
    onset = Screen('Flip',params{2}); 
end

% params(1): stim handle
function SFLAuditoryOn(params)
    global sfm_stimuli;
    stim_data = sfm_stimuli.auditory(params{1});
    PsychPortAudio('Start', stim_data.pahandle, stim_data.repeat,0); %starts sound immediatley
end


% params(1): stim type ('visual' or 'auditory')
% parmas(2): params for subfunctions...
function ret = SFLOff(params)
    if isempty(params{1})
        error('SFL error: SFLOff not provided a stimulus type');
    end
    
    switch params{1}
        case 'visual'
            SFLVisualOff(params(2:end));
        case 'auditory'
            SFLAuditoryOff(params(2:end));
        otherwise
            error('SFL error: SFLOff given bad stimulus type');
    end
    
    ret = 1;
end

% params(1): stim handle
function SFLVisualOff(params)
    global sfm_stimuli;
    stim_data = sfm_stimuli.visual(params{1});
    Screen('FillRect', stim_data.window ,stim_data.bgcolor, stim_data.shaperect);
    Screen('Flip',params{2}); 
end

% params(1): stim handle
function SFLAuditoryOff(params)
    PsychPortAudio('Stop', params{1});% Stop sound playback
end

function SFLShutdown()
    %iterate through all sound stimuli and close the audio handles
end




