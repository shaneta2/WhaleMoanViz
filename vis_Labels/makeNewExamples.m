function makeNewExamples()
    
% makeNewExamples: creates new training examples from detections
%
% This script saves all of the existing and new detections (saves edits)
% and calls a python script which creates new training examples for a model.
% Since the model only saves spectrograms for segments where it finds
% detections, this script must create and save spectrograms for any FP
% detections. It also dumps all of the detections into a file in the format
% accepted by the model so that it can be retrained on the new data.
% Created by Shane Andres

    global REMORA PARAMS

    wmvControl('SaveEdits');

    % get path to verified detections
    if ~isfield(REMORA.lt.lVis_det, 'verifiedFilePath')
        disp('Error making new examples: no verified detections file found');
        return
    else
        verifiedFilePath = REMORA.lt.lVis_det.verifiedFilePath;
    end

    % select where new detections should be saved to
    [examplesFileName, examplesFolder] = uiputfile('*.txt', 'Select location to save new examples', strcat(PARAMS.inpath, '/new_examples.txt'));
    if isequal(examplesFileName,0) || isequal(examplesFolder,0) % triggers when user clicks cancel in file save popup
       disp('New example creation cancelled.')
       return
    end
    examplesFilePath = strcat(examplesFolder, examplesFileName);

    % move to WMD directory
    origDir = pwd;
    cd(REMORA.lt.lVis_det.wmdFolder + "/code")

    % format file paths (windows backslashes are interpreted as escape sequences)
    verifiedFilePath = replace(string(verifiedFilePath), '\', '/');
    examplesFilePath = replace(string(examplesFilePath), '\', '/');

    % run python code to create new examples in a popup cmd window
    pythonExe = REMORA.lt.lVis_det.pyenvFolder + "/python.exe";
    pyCode = 'from make_new_examples import *; make_new_examples(\"' + ... % python code to run make_new_examples function
        verifiedFilePath + '\", \"' + ...
        examplesFilePath + '\")';

    pythonCmd = sprintf('\"%s\" -u -c \"%s\"', pythonExe, pyCode); % formatting to run python from the cmd line
    sysCmd = sprintf('start cmd.exe /k "%s"', pythonCmd);
    system(sysCmd); % running python code in a new cmd window

    % move back to original directory
    cd(origDir)

end