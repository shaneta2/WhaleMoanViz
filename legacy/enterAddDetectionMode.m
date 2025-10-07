function enterAddDetectionMode()

% enterAddDetectionMode: prepares spectrogram for a user to input a detection.
%
% This entire script is now within the main control script
% (wmvControl).


    global HANDLES

    disp('Click and drag on the spectrogram to add a new detection.');
    
    % Set up normal click for adding a bounding box
    set(HANDLES.fig.main, 'WindowButtonDownFcn', @addDetection);

end

