
function initializeDetectionFields(data)

% initializeDetectionFields: Populates the "detection" data structure
% (used when plotting bounding boxes)
%
% The information for each detected / added bounding box audio is stored in 
% a dataTable which is updated whenever a bounding box is modified.
% The "detection" data structure stores a copy of this
% information, which is used for plotting each bounding box, and 
% it must be updated whenever the dataTable is. This script is used to 
% populate the "detection" data structure.
% 
% Note that the dataTable is passed in as an argument.
% Created by Michaela Alksne

    global REMORA

     % Sort data by start_time
    data = sortrows(data, 'start_time');
    
    % Convert datetime to numerical format (days since epoch)
    excelEpoch = datetime(2000, 1, 0);
    REMORA.lt.lVis_det.detection.starts = days(data.start_time - excelEpoch);
    REMORA.lt.lVis_det.detection.stops = days(data.end_time - excelEpoch);
    REMORA.lt.lVis_det.detection.labels = data.label;
    REMORA.lt.lVis_det.detection.min_freq = data.min_frequency;
    REMORA.lt.lVis_det.detection.max_freq = data.max_frequency;
    REMORA.lt.lVis_det.detection.score = data.score;
    REMORA.lt.lVis_det.detection.pr = data.pr;
    
end
