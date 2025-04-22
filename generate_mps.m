function generate_mps(input_directory, path_main_fold , brainstorm_protocol)
    %%% Function saves mps in brainstorm database for visualization 
    %%% written by M.I. Pescaru, after script by P. Albouy (2024), using ModFilter
    %%% algorithm developed by T. Elliott and F. Theunissen (2009)
  
    

    %% parameters and paths
    smoo = 3; % smoothing of the modulogram
    currentfolder = fullfile(path_main_fold,'ModifiedScripts'); % path for the folder Modified scripts - ModFilter Toolbox
    addpath(currentfolder);
    addpath(path_main_fold);
    addpath(genpath([path_main_fold, 'brainstorm3'])); 

    data_path = fullfile(path_main_fold, input_directory); %%song folder
    Stim = dir(fullfile(data_path, '*.wav')); %%extract list of songs in song folder 
    cd(data_path);


    for i = 1:length(Stim) %%loop through all the song files 

        disp (Stim(i).name);

        [Y,FS] = audioread(Stim(i).name); %%extracts audio from file 
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% Temporal modulation
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            label = {'test'};
            temporal = [1 ];
            
            songnumber = 1;
            %     disp('%%%%%%%%%%%%%%%%')
            %     disp(['Song number', num2str(songnumber)])
            temp = 1;
            
            filter.method = 1;           % 1: Notch Filter/ 2: High pass/ 3: Low pass/ 4: No filter
            filter.fband = 32;           % fband is the width of the frequency band - use 32 Hz for speech - 125 Hz for zebra finch song
            filter.wf_high = 0.00;%temporal(temp);         % Frequencial cutoff frequency
            filter.wt_high = temporal(temp);          % Temporal cutoff frequency
            filter.wf_it = inf;            % Width of the spectral mask (Notch filter)
            filter.wt_it = Inf;            % Width of the temporal mask (Notch filter)
           
            
            %% make sound pressure file from wav file
 

            fs =FS;
            song_in = Y;%concat_Y;% Y(0.5*FS:end,1);%(1:end,1);
            
            
            
            sound_in =song_in ;
            samprate =fs ;
            fband= filter.fband ;
            method = filter.method;
            wf_high =filter.wf_high;
            wt_high = filter.wt_high;
            wf_it =filter.wf_it;
            wt_it = filter.wt_it;
            filter = filter;
            
            
            %% Some parameters: these could become flags
            nstd = 6;
            twindow = 1000*nstd/(fband*2.0*pi);        % Window length in ms - 6 times the standard dev of the gaussian window
            winLength = fix(twindow*samprate/1000.0);  % Window length in number of points
            winLength = fix(winLength/2)*2;            % Enforce even window length
            increment = fix(0.001*samprate);           % Sampling rate of spectrogram in number of points - set at 1 kHz
            ampsrate = samprate/increment;
            f_low=250;                                 % Lower frequency bounds to get average amplitude in spectrogram
            f_high=10000;                              % Upper frequency bound to get average amplitude in spectrogram
            sil_len=500;                               % Amount of silence added at each end of the sound and then subracted
            tone_ramp=25;                              % tone ramp in ms
            
            debug_fig = 0;                             % Set to 1 to see spectrograms, 2 to see just resulting spectra, 0 to run many files without creating figures.
            save_fig = 0;                              % Set to 1 to save data to recreate images
            data_path = './DataFiles/';                % Specify folder if you wish to save data
            no_it = 20;                                % The number of iterations for the spectrum inversion
            logflg = 1;                                % Perform the mod spectrum in log or linear amplitudes
            DBNOISE = 80;                              % dB in Noise for the log compression - values below will be set to zero.
            
            % This defines the ramp of the gain from 0 to 1
            dfi=0.0001;                                % 0.1 cycle per kHz ramp in frequency
            dti=1;                                     % One Hz ramp in time
            
            
            soundlen = length(sound_in);
            
            % Force sound_in to have zero mean.
            sound_in = sound_in - mean(sound_in);
            sound_in = sound_in / max(abs(sound_in));                    
            
            % find the length of the spectrogram and get a time label in ms
            maxlenused = soundlen+fix(sil_len*2.0*(samprate/1000.0));
            maxlenint = ceil(maxlenused/increment)*increment;
            w = hamming(maxlenint);
            frameCount = floor((maxlenint-winLength)/increment)+1;        
            
            % Pad the sound with silence (silence added at beginning of sound)      
            input = zeros(1,maxlenint);
            nzeros = fix((maxlenint - soundlen)/2);
            input(1+nzeros:nzeros+soundlen) = sound_in;
           
            [s, to, fo, pg] = GaussianSpectrum(input, increment, winLength, samprate);  % Gaussian Spectrum called here to get size of s and fo
      
            fstep = fo(2)-fo(1);
            fl = floor(f_low/fstep)+1;        % low frequency index to get average spectrogram amp
            fh = ceil(f_high/fstep)+1;        % upper frequency index to get average spectrogram amp
            sabs = abs(s).^2;
            
            
            sphase = s;
            %clear s;
            maxsabs = max(max(sabs));
            
            sabsDisp = 20*log10(sabs./maxsabs)+DBNOISE;
            sabsDisp(find(sabsDisp<0.0)) = 0.0;
            
            if logflg
                sabs = sabsDisp;
            end
            
            nb = size(sabs,1);
            nt = length(to);
            
            % variables to save figure data
            if save_fig
                toInitial = to;
                foInitial = fo;
            end
            
            
            
            % Find the mean level of the amplitude envelope as a function of frequency
            meanf = mean(sabs');
            meant = mean(sabs);
            
            % calculate the 2D fft
            %fabs = fft2(sabs);      % Modulation domain
            mps_raw = abs (fft2(sabs));
            mps_log = 10 * log10(fftshift(mps_raw) + 1e-10); 
            maxMPS = max(mps_log(:)); 
            minMPS = maxMPS - 50; 
            mps_log(mps_log < minMPS) = minMPS; 
            mps_smooth = imgaussfilt(mps_log, smoo);
            mps_norm = mps_smooth - min(mps_smooth(:));
            test = mps_norm; 
           
            fstep = fo(2);
            
            for ib=1:ceil((nb+1)/2)
                dwf(ib)= (ib-1)*(1/(fstep*nb));
                if (ib > 1)
                    dwf(nb-ib+2)=-dwf(ib);
                end
            end
            
            % ampsrate is the sampling rate of the amplitude enveloppe
            for it=1:ceil((nt+1)/2)
                dwt(it) = (it-1)*(ampsrate/nt);
                if (it > 1 )
                    dwt(nt-it+2) = -dwt(it);
                end
            end
            im = rescale(test,0,255);
            im =uint8(im);
            imB = imresize(im,[659,6015]);
            test = rescale(im2double(imB),min(min(test)), max(max(test)));
            
            %%loads brainstorm procedure 
            
                 
                 load(fullfile(path_main_fold,'mask.mat'));
                 load(fullfile(path_main_fold,'ref_5s.mat'));
                
                var = fullfile(path_main_fold, 'brainstorm_database\STM\data\ADS_Corpus\ADS\brainstormstudy.mat');
                disp(var);
                [~,iStudy] = bst_get('Study',file_fullpath(var));
                disp(iStudy);
                %%loads framework for results 
                results = load([path_main_fold,'\brainstorm_database\',brainstorm_protocol,'data\ADS_Corpus\ADS\timefreq_morlet_reference.mat']);
           %%

            clear testTF
            for tre =1:29
                testTF(tre,:,:) = test';
                %disp(testTF(tre));
            end
            %%loads results 
            results.TF = testTF(:,2767:3249,330:529);
            results.TFmask = s';            
            results.Time = fftshift(dwt);
            results.Time = results.Time(2767:3249);
            results.RowNames{1,1} = Stim(1).name(1:end-4); 
            results.Comment = ['S',num2str(smoo),'_',Stim(i).name(1:end-4)];
            results.Freqs = fftshift(dwf).*1000;
            results.Freqs =  results.Freqs(330:529);
            %%stores the new name of the timefreq result file 
            fname = ([path_main_fold,'\brainstorm_database\',brainstorm_protocol,'data\ADS_Corpus\ADS\timefreq_morlet_S',num2str(smoo),'_',Stim(i).name(1:end-4)]);
            fname = file_unique(fname);
            bst_save(fname,results,'v6'); %%saves results in brainstorm database 
            db_add_data(iStudy,fname,results);
            db_reload_studies(iStudy);
  
    end 
    cd(path_main_fold);
    