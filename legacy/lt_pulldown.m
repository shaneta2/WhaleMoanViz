function lt_pulldown(action)

% lt_pulldown: Called to handle clicks in the control window Remora pulldown
%
% This script  appears to handle any button click within the Remora's
% dropdown menu. This menu appears under the "Remoras" dropdown inside of
% the command window.
%
% The script activates an event handler which handles obsolete click
% events. It also sets up 8 containers to hold different sets of labels. In
% the old Remora, this was probably to allow for multiple sets of labels
% to be shown at once (from different files). In the new Remora, only one 
% set of labels is used at a time so everything beyond the first is obsolete.
% This makes this entire callback function obsolete. Instead, it can be skipped 
% and wmvWindow can be called.

global PARAMS REMORA HANDLES
    
if strcmp(action,'visualize_labels')
    %visualize tlabs for plotting
    REMORA.lt.lVis_params = lt_lVis_init_settings; % (OBSOLETE)
    lt_init_lVis_window
    set(HANDLES.fig.main,'WindowKeyPressFcn',@lt_keyAction)
    
    % initialize settings needed for plotting
    % (these initialize each label set to start off as hidden.)
    REMORA.lt.lVis_det.detection.PlotLabels = false;
    REMORA.lt.lVis_det.detection2.PlotLabels = false;
    REMORA.lt.lVis_det.detection3.PlotLabels = false;
    REMORA.lt.lVis_det.detection4.PlotLabels = false;
    REMORA.lt.lVis_det.detection5.PlotLabels = false;
    REMORA.lt.lVis_det.detection6.PlotLabels = false;
    REMORA.lt.lVis_det.detection7.PlotLabels = false;
    REMORA.lt.lVis_det.detection8.PlotLabels = false;
    
    %initialize settings for auto-updates in triton window
    if ~isfield(REMORA,'ltsa_plot_lVis_lab')
        REMORA.ltsa_plot_lVis_lab = {};
    end
    REMORA.ltsa_plot_lVis_lab{end+1} = @lt_lVis_plot_LTSA_labels;
    REMORA.ltsa_plot_lVis_lab{end+1} = @lt_lVis_plot_WAV_labels;
    REMORA.ltsa_plot_lVis_lab{end+1} = @lt_lVis_plot_TS_labels;

end