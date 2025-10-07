function [boutStarts,boutStops] = lt_lVis_defineBouts(starts,stops,boutGap)

% lt_lVis_defineBouts: function for creating bout-level times from click detections 
%
% This function groups individual detections into bouts based on if they
% occur within some time threshold, boutGap. The start and end times of
% each individual detection are stored within the lists start and stop.
% The bouts are then stored within a Remora global variable.
%
% The below commented code used to be inside of lt_lVis_control, inside of
% the LoadLabels section. This is no longer needed, as WMV does not use
% bouts.

% %calculate LTSA bouts
% %%% shorten detections to bout-level
% boutGap = datenum(0,0,0,0,0,15); %if spacing between start of detections...
% %is less than this, combine into a bout
% [REMORA.lt.lVis_det.detection.bouts.starts,REMORA.lt.lVis_det.detection.bouts.stops] = lt_lVis_defineBouts(...
%     REMORA.lt.lVis_det.detection.starts, ...
%     REMORA.lt.lVis_det.detection.stops, ...
%     boutGap);

%if starts and stops are not chronological, reorder
% We should do this when tlabs are loaded as opposed to each time
%starts = sort(starts);
%stops = sort(stops);

nextDet = [starts(2:end);stops(end)];
detDiff = nextDet - stops;

boutStops = [stops(detDiff >= boutGap);stops(end)];
nextBout = nextDet(detDiff >=boutGap);
%next bout needs to be adjusted to correspond with the correct ends
boutStarts = [starts(1); nextBout(1:end)];