function openFile(infile, inpath)

% openFile: default code to open a WAV or XWAV file, taken straight from Triton
% 
% This code is taken from the openwav function within 'filepd.m'
% in Triton. If code changes there, this code will need to be updated. 
% This code enables the functionality of the 'Previous File' and 'Next
% File' buttons. Note that this only works for .wav files.
%
% This code is necessary because Triton does not offer a function for
% opening a .wav file using the file name and path as arguments. The only
% outwards-facing function requires that the user find the desired file in
% a file explorer pop-up.
% Adapted from Triton 'filepd.m' by Shane Andres

    global HANDLES PARAMS DATA

    PARAMS.infile = infile;
    PARAMS.inpath = inpath;
    % get audio file extension
    parts = strsplit(infile, '.');
    if numel(parts) >= 3
        ext = ['.' parts{end-1} '.' parts{end}];  % combine last two parts
    else
        ext = ['.' parts{end}];  % fallback to last extension
    end

    if isequal(ext, '.wav')
    
        disp_msg('Opened File: ')
        disp_msg([PARAMS.inpath,PARAMS.infile])
        cd(PARAMS.inpath)
      
        set(HANDLES.fig.ctrl, 'Pointer', 'watch');
        PARAMS.ftype = 1;
        % enter start date and time
        prompt={'Enter Start Date and Time'};
        dnums = wavname2dnum(PARAMS.infile);
        if isempty(dnums)
            PARAMS.start.dnum = datenum([0 1 1 0 0 0]);
        else
            PARAMS.start.dnum = dnums - datenum([2000 0 0 0 0 0]);
        end
        def={timestr(PARAMS.start.dnum,6)};
        dlgTitle=['Set Start for File : ',PARAMS.infile];
        lineNo=1;
        AddOpts.Resize='on';
        AddOpts.WindowStyle='normal';
        AddOpts.Interpreter='tex';
        in=inputdlg(prompt,dlgTitle,lineNo,def,AddOpts);
        if length(in) == 0	% if cancel button pushed
            PARAMS.cancel = 1;
            return
        end
        % time delay between Auto Display
        PARAMS.start.dnum=timenum(deal(in{1}),6);
        % initialize data format
        initdata
        if isempty(DATA)
            set(HANDLES.display.timeseries,'Value',1);
        end
        readseg
        plot_triton
        control('timeon')   % was timecontrol(1)
        % turn on other menus now
        control('menuon')
        control('button')
        set([HANDLES.motion.seekbof HANDLES.motion.back HANDLES.motion.autoback HANDLES.motion.stop],...
            'Enable','off');
        set(HANDLES.motioncontrols,'Visible','on')
        init_tslider(0)
        if PARAMS.nch > 1
            set(HANDLES.mc.on,'Visible','on');
            %         set(HANDLES.mc.off,'Visible','on');
        end

    elseif isequal(ext, '.x.wav')

        disp_msg('Opened File: ')
        disp_msg([PARAMS.inpath,PARAMS.infile])
        cd(PARAMS.inpath)

        % calculate the number of blocks in the opened file
        set(HANDLES.fig.ctrl, 'Pointer', 'watch');
        PARAMS.ftype = 2;
        initdata
        if ~isempty(PARAMS.xhd.byte_length)
            PARAMS.plot.initbytel = PARAMS.xhd.byte_loc(1);
        end
        if isempty(DATA)
            set(HANDLES.display.timeseries,'Value',1);
        end
        readseg
        plot_triton
        control('timeon')
        % turn on other menus now
        control('menuon')
        control('button')
        set([HANDLES.motion.seekbof HANDLES.motion.back HANDLES.motion.autoback HANDLES.motion.stop],...
            'Enable','off');
        set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
        set(HANDLES.motioncontrols,'Visible','on')
        set(HANDLES.delimit.but,'Visible','on')
        if PARAMS.nch > 1
            set(HANDLES.mc.on,'Visible','on');
            %         set(HANDLES.mc.off,'Visible','on');
        elseif PARAMS.nch == 1
            set(HANDLES.multi,'Visible','off');
        else
            disp_msg(['Error number of channels : ', num2str(PARAMS.nch)])
        end
        init_tslider(0)

    else

        disp("Error: unrecognized audio file format. Accepted formats are .wav and .x.wav")

    end

end