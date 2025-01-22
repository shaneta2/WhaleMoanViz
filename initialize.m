global REMORA HANDLES

% initialization script for label tracking remora

REMORA.lt.menu = uimenu(HANDLES.remmenu,'Label','&WhaleMoanViz',...
    'Enable','on','Visible','on');

uimenu(REMORA.lt.menu, 'Label', 'Visualize Labels', ...
    'Callback', 'lt_pulldown(''visualize_labels'')');


if ~isfield(REMORA,'fig')
    REMORA.fig = [];
end