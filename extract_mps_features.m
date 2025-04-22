function extract_mps_features(mps_folder, output_csv) 
    
    %%Function extracts features from the MPS of the files as mps_folder:
    %%asymmetry, low-pass coefficient, starriness and
    %%saves everything in a csv file 
    %%% Feature calculation follows definitions by F.T. Theunnissen (2003)


    files = dir(fullfile(mps_folder, 'timefreq_morlet_S3_*.mat'));
    results_table = []; 
    

    for i = 1:length(files)
        fname = fullfile(mps_folder, files(i).name); 
        disp(fname);
        results = load(fname); 
        MPS = squeeze(results.TF(1, :, :)); 
        MPS = MPS'; 
        MPS = MPS - min(MPS(:)); 
        %{
        if max(MPS(:)) > 0
            MPS = MPS/ max(MPS(:)); 
        end
        %}
        freq_axis = results.Freqs/1000; 
         
        time_axis = results.Time; 
         
        %% Asymmetry 
        pos_freq_idx = find(freq_axis > 0); 
        MPS_pos = MPS(pos_freq_idx, :); 
        %disp(MPS_pos);

        pos_time_idx = find(time_axis > 0); 
        neg_time_idx = find(time_axis < 0); 

        E_up = sum(MPS_pos(:, neg_time_idx), 'all');
        E_down = sum(MPS_pos(:, pos_time_idx), 'all'); 
        %disp(E_up); 
        %disp(E_down); 

        if (E_up + E_down) == 0
            asym = 0; 
        else 
            asym = (E_down - E_up) / (E_up + E_down); 
        end 

        %% Low-Pass Coefficient 
        f_cutoff = 0.195;
        t_cutoff = 5.0;

        msk_f_idx = find(abs(freq_axis) <= f_cutoff/1000); 
        msk_t_idx = find(abs(time_axis) <= t_cutoff); 
        MPS_freq_lowpass = MPS(msk_f_idx, :); 
        MPS_lowpass = MPS_freq_lowpass(:, msk_t_idx); 

        E_lowpass = sum(MPS_lowpass(:), 'all'); 
        E_total = sum(MPS, 'all'); 
        %disp(E_total); 
        lowpass_coeff = E_lowpass/E_total; 

        %%Starriness
        [~, f0_idx] = min(abs(freq_axis)) ; 
        [~, t0_idx] = min(abs(time_axis)) ; 
        %disp(time_axis); 
        
        %disp(t0_idx);
        E_faxis  = sum(MPS(f0_idx, :), 'all');
        

        E_taxis = sum(MPS(:, t0_idx), 'all'); 
        
        dc = MPS(f0_idx, t0_idx);
        fprintf('For file %s, E_faxis is %d, E_taxis is %d, E_dc is %d and E_total is %s \n', fname, E_faxis, E_taxis, dc, E_total); 
        E_axes = E_faxis + E_taxis - dc ; 
        starriness = E_axes / E_total; 

        %%Modulation Depth
        mod_depth = dc / E_total; 

        %%Store everything
        results_table(end+1).Filename = files(i).name; 
        results_table(end).Asymmetry = asym; 
        results_table(end).ModDepth = mod_depth; 
        results_table(end).Starriness = starriness; 
        results_table(end).LowPassCoeff = lowpass_coeff; 
    end 

    %Convert to csv file
    T = struct2table(results_table); 
    writetable(T, output_csv); 
    fprintf('Saved MPS features to %s\n', output_csv); 