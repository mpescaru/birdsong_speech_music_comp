function average_species (path_main_fold)
    species = {'00057', '00072', '00218', '00333', '00342', '00398', '00407', '00417', '00441', '00452', ...
        '00480', '00482', '00484', '00487', '00488', '00507', '00511', '00543', '00545', '00547', ...
        '00552', '00673', '00677', '00687', '00697', '00740', '00985', '01002', '01053', '01161', ...
        '01342', '01490', '01558', '01892', '02023', '02038', '02076', '02078', '02084', '02090',...
        '02107', '02121', '02140', '02148', '02233', '02377', '02394', '02454', '02554', '02640', ...
        '02644', '02647', '02649', '02659', '02662', '02665', '02666', '02671', '02673', '02675', ...
        '02676', '02678', '02679', '02701', '02714', '02740', '02741', '02751', '02773', '02788', ...
        '02789', '02799', '02808', '02810', '02881', '02949', '03000', '03011', '03083', '03090', ... 
        '03093', '03108', '03129', '03134', '03140', '03143', '03146', '03151', '03156', '03183', ...
        '03191', '03192', '03196', '03221', '03222', '03242', '03245', '03255', '03260', '03261', ...
        '03265', '03273', '03356', '03405', '03408', '03410', '03475', '03482', '03600', '03649', ...
        '03673', '03768', '03769', '03772', '03773', '03778', '03782', '03783', '03784', '03976', ...
        '03978', '03980', '03981', '04000', '04003', '04004', '04005', '04017', '04030', '04048', ...
        '04049', '04051', '04093', '04104', '04109', '04123', '04125', '04126', '04134', '04135', ...
        '04136', '04137', '04142', '04150', '04155', '04155', '04157', '04158', '04159', '04162', ...
        '04370', '04377', '04398', '04415', '04416', '04430', '04433', '04441', '04504', '04576', ...
        '04611', '04626', '04634', '04635', '04638', '04672', '04674', '04677', '04707', '04722', ...
        '04760', '04767', '04769', '04829', '04893', '04913', '05005', '05036', '05058', '05092', ...
        '05327', '05333', '05279', '05440', '05508', '05509', '05535', '05557', '05565', '05567', ...
        '05570', '05583', '05584', '05585', '05635', '05637', '05643', '05644', '05645', '05647', ...
        '05650', '05642', '05654', '05665', '05677', '05683', '05685', '05686', '05687', '05689', ...
        '05690', '05691', '05694', '05698', '05707', '05713', '05714', '05729', '05733', '05734', ...
        '05737', '05741', '05743', '05791', '05800', '05827', '05836', '05837', '05838', '05841', ...
        '05842', '05862', '05943', '05947', '05959', '05960', '05963', '05969', '05970', '05977', ...
        '05985', '05986', '05991', '05993', '05996', '06001', '06007', '06011', '06020', '06036', ...
        '06047', '06049', '06052', '06073', '06075', '06078', '06098', '06113', '06114', '06115', ...
        '06134', '06224', '06302', '06342', '06406', '06409', '06410', '06414', '06415', '06419', ...
        '06421', '06423', '06435', '06442', '06473'};
      species_batch2 ={  '06485', '06495', '06507', '06511', '06512', '06514', '06520', '06524', '06525', '06538', '06540', '06552', '06559', ...
        '06560', '06561', '06562', '06565', '06566', '06567', '06584', '06586', '06589', '06593', '06594', '06599', '06609', '06614', ...
        '06620', '06624', '06625', '06626', '06629', '06630', '06636', '06637', '06639', '06644', '06656', '06666', '06669', '06675', ...
        '06679', '06687', '06692', '06694', '06695', '06700', '06712', '06717', '06723', '06724', '06726', '06727', '06729', '06731', ...
        '06737', '06744', '06745', '06747'}; 
       
    suboscines = { '00057', '00072', '00218', '00333', '00342', '00398', '00407', '00417', '00441', '00452', ...
        '00480', '00482', '00484', '00487', '00507', '00511', '00543', '00545', '00547', '00552', '00673', ...
        '00687', '00697', '00740', '00985', '01002', '01053', '01161', '01342'};

    ads_corpus_path = fullfile(path_main_fold, '\brainstorm_database\STM\data\ADS_Corpus\ADS');
 
    DATA_OSCINES = []; 
    DATA_SUBOSCINES = []; 
    osi = 1; 
    subi = 1; 
    
    for si = 1:length(species)
    
        DATA = []; 
        tfreq_species = dir(fullfile(ads_corpus_path, ['*' species{si} '*.mat'])); 
        if (length(tfreq_species)>=1)
            species_name = tfreq_species(1).name(39:length(tfreq_species(1).name)-24);
        
        disp(length(tfreq_species));
        for i = 1:length(tfreq_species)
            tfreq_cur = load(fullfile(ads_corpus_path, tfreq_species(i).name));
            DATA(i,:,:) = squeeze(tfreq_cur.TF(1,:,:));
        end 
        pp =12;
        minc = 10;
        maxc  =12;
        d_m = mean(DATA,1);
        if ismember(species{si}, suboscines)
            DATA_SUBOSCINES(subi, :, :) = d_m;
            subi = subi + 1; 
        else 
            DATA_OSCINES(osi, :, :) = d_m; 
            osi = 1; 
        end 
        load(fullfile(path_main_fold,'CCMAP.mat'));
        t = tfreq_cur.Time;
        f =tfreq_cur.Freqs;
        imagesc(t, f,squeeze(d_m)');% ,'Interpolation', 'bilinear');
        title('Spectrotemporal Modulations');
        axis xy;
        axis([-30 30 0 5]);
        colormap(CustomColormap)
        colorbar;
        caxis([minc maxc])
%      set(gca,'FontSize',pp);
        xlabel('Temporal Modulations (Hz)','Fontsize',pp);
        ylabel('Spectral Modulations (cyc/kHz)','Fontsize',pp);
        set(gcf,'Color','w')
        title([species_name '_average']);
       
       song = squeeze(d_m)';
       saveas(gcf,['output\average_species_figures\figure_species',species{si}, species_name '.png']);
        end 
    end 

        avg_os = mean(DATA_OSCINES, 1); 
        avg_sub = mean(DATA_SUBOSCINES, 1);
        t= tfreq_cur.Time;
        f=tfreq_cur.Freqs;
        imagesc(t, f,squeeze(avg_os)');% ,'Interpolation', 'bilinear');
        title('Spectrotemporal Modulations');
        axis xy;
        axis([-15 15 0 9]);
        colormap(CustomColormap)
        colorbar;
        caxis([minc maxc])
%      set(gca,'FontSize',pp);
        xlabel('Temporal Modulations (Hz)','Fontsize',pp);
        ylabel('Spectral Modulations (cyc/kHz)','Fontsize',pp);
        set(gcf,'Color','w')
        title([ 'oscines_average']);

       saveas(gcf,['output\average_species_figures\figure_oscines.png']); 
        
       imagesc(t, f,squeeze(avg_sub)');% ,'Interpolation', 'bilinear');
        title('Spectrotemporal Modulations');
        axis xy;
        axis([-15 15 0 9]);
        colormap(CustomColormap)
        colorbar;
        caxis([minc maxc])
%      set(gca,'FontSize',pp);
        xlabel('Temporal Modulations (Hz)','Fontsize',pp);
        ylabel('Spectral Modulations (cyc/kHz)','Fontsize',pp);
        set(gcf,'Color','w')
        title(['suboscines_average']);

       saveas(gcf,['output\average_species_figures\figure_suboscines.png']); 

    for si = 1:length(species_batch2)
    
        DATA = []; 
        tfreq_species = dir(fullfile(ads_corpus_path, ['*' species_batch2{si} '*.mat'])); 
        if (length(tfreq_species)>=1)
            species_name = tfreq_species(1).name(34:length(tfreq_species(1).name)-24);
        
        disp(length(tfreq_species));
        for i = 1:length(tfreq_species)
            tfreq_cur = load(fullfile(ads_corpus_path, tfreq_species(i).name));
            DATA(i,:,:) = squeeze(tfreq_cur.TF(1,:,:));
        end 
        pp =12;
        minc = 10;
        maxc  =12;
        d_m = mean(DATA,1);
        load([path_main_fold,'CCMAP.mat']);
        t = tfreq_cur.Time;
        f =tfreq_cur.Freqs;
        imagesc(t, f,squeeze(d_m)');
        title('Spectrotemporal Modulations');
        axis xy;
        axis([-30 30 0 5]);
        colormap(CustomColormap)
        colorbar;
        caxis([minc maxc])
%      set(gca,'FontSize',pp);
        xlabel('Temporal Modulations (Hz)','Fontsize',pp);
        ylabel('Spectral Modulations (cyc/kHz)','Fontsize',pp);
        set(gcf,'Color','w')
        title([species_name '_average']);
       
       song = squeeze(d_m)';
       saveas(gcf,['output\average_species_figures\figure_species',species_batch2{si}, species_name '.png']);
        end 
    end 
        