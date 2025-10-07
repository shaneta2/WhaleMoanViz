function [first, last] = getDetectionRange(start, stop, varargin)

% getDetectionRange: find the indices of the first and last detections within some range
%
% This script is used to find the indices of the detections that lie within
% the visible spectrogram window. All detections which have a start or stop
% within the window will be plotted. Note that the list of starts and
% stops are both passed in as date array arguments.
% Adapted from lt_lVis_get_range by Michaela Alksne
% 
% inputs:
% start, stop - Matlab serial dates (datenum)
% date1, date2, ... - Arrays of related serial dates all of the same size.
%    Operates on each date vector spearately and assumes that the vectors
%    are related to one another (e.g. different measurements on the same
%    event such as start and end time).
%
%    For each date vector, we find:
%    values(first) - First date > start
%    values(last) - Last date < stop
%
%    When multiple date vectors are passed in, we merge all indices,
%    first = min([first1, first2, ...])
%    last = max([last1, last2, ...])
%
% outputs:
% [first, last] - array containing the first and last indices. If such a
% detection does not exist within the range, first = [] and last = [].

    first = Inf;
    last = -Inf;
    
    for idx = 1:length(varargin)
        dates = varargin{idx};
        
        vfirst = binarysearch(start, dates, 1);
        vlast = binarysearch(stop, dates, -1);
    
        if vfirst <= vlast
            % good range, update 
            first = min(first, vfirst);
            last = max(last, vlast);
        end
    end
    
    if isinf(first) || isinf(last) 
        % nothing found
        first = [];
        last = [];
    end
    
end
    
function idx = binarysearch(target, values, direction)

% binarysearch: helper function to find the nearest detection to some
% time stamp
%
% Given a set of values, this function finds the index of values such that:
% direction 1:
%     values(idx) is the first item such that values(idx) >= target
% direction -1:
%     values(idx) is the last item such that values(idx) <= target
    
    N = length(values);
    % Handle no search cases where target is before the start
    % or after the end, then invoke the binary search helper
    if direction == 1 && (target > values(end))
        % First value after target: no such value
        idx = Inf;
    elseif direction == -1 && (target < values(1))
        % Last value before target: no such value
        idx = -Inf;
    else
        % Perform a binary search to find it.
        idx = searchhelper(1, N, target, values, direction);
    end

end
    
function idx = searchhelper(low, high, target, values, direction)

% searchhelper: helper function to implement binary search recursion
% 
% Given a target and a set of sorted values, this function finds the index
% of the first item in values after value (direction = 1)
% or the last item in values before value (direciton = -1)
% within the range values[low] and values[high]
    
    midpt = floor((high - low) / 2) + low;
    if ismember(midpt, [low, high])
        % low and high are consecutive
        % Base case of recursion, need to make a decision
        switch direction
            case 1
                % First value past target
                if target <= values(low) 
                    idx = low;
                else
                    idx = high;
                end
            case -1
                % Last value before target
                if target < values(high)
                    idx = low;
                else
                    idx = high;
                end
        end
    else
        % Need to narrow range between low and high
        % Find out which side the midpoint the target is on and search
        if target < values(midpt)
            high = midpt;
            idx = searchhelper(low, high, target, values, direction);
        else
            low = midpt;
            idx = searchhelper(low, high, target, values, direction);        
        end
    end

end