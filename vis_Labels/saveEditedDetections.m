
function saveEditedDetections(fileFullPath)
    global REMORA

    % Access the main data table
    data = REMORA.lt.lVis_det.dataTable;

    % Modify file name to include "verified" instead of "raw"
    [folder, name, ext] = fileparts(fileFullPath);
    verifiedFileName = strrep(name, 'raw', 'verified');
    verifiedFilePath = fullfile(folder, [verifiedFileName, ext]);
    
    % Write the updated data table to the new file
    try
        writetable(data, verifiedFilePath, 'Delimiter', '\t');  % Save as tab-delimited file
        disp(['Edits successfully saved to ', verifiedFilePath]);
    catch ME
        disp('Error saving edits to file:');
        disp(ME.message);
    end
end
