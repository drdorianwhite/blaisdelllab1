% file: stim_functions.m
% author: Lehel KOvach
% date: 10/31/2017
% title: Stimuli Functions Library
% description:  contains utility functions for displaying visual shape stimuli and
% auditory tone stimuli.  these functions allow for control of location,
% color/frequency and show/hide. 
%
% The library is interfaced by the single function: SFLCall, which takes
% specific string values representing the functions in this library (i.e.,
% 'create', 'on', 'off' and 'modify' and the second parameter being
% a matrix containing the input parameters for the function
% A stimuli that is instatiated through the functions, 'Create'  return a value that
% represents a handle to the stimulus.  to present the stimulus, call
% 'On' passing this handle as the the first parameter.  Likewise for
% stopping the presentation with 'Off'.  To change any parameters of a
% created stimulus (i.e., changing its color, position, frequency, etc,)
% call the function 'Modify' with the handle of the stimulus

function SFLCall(sfl_func_name, params)
    if empty(sfl_func_name)
        error('SFL error: SFLCall not provided a function name');
    end
    
    switch sfl_func_name
        case 'create'
            SFLCreate(params);
        case 'on'
            SFLOn(params);
        case 'off'
            SFLOff(params);
        case 'modify'
            SFLModify(params);
        otherwise
            error('SFL error: function name supplied does not exist!');
    end

end

    
function SFLInit()
    global sfm_initialized;
    global sfm_handle_counter;
    global sfm_stimuli;
    
    if isempty(sfm_initialized) 
        sfm_initialized = 1;
        sfm_handle_counter = 0;
        sfm_stimuli.visual = [];
        sfm_stimuli.auditory = [];
    end    
end



