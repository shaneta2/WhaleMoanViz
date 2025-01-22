
function initializeDetectionFields(data)
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
