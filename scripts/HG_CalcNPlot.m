function [iFgNrNew, Results] = HG_CalcNPlot(PlotID, Data, iFgNr)
arguments
    PlotID
    Data
    iFgNr = -1; %figure will not be created
end


[fg, iFgNrNew] = addFindFigure(PlotID, iFgNr);

switch PlotID
    case 'PL_DNAonDOY&Depth'
        tStPredictors = Data.tStPredictors;
        DMAComponents = 15:20;
        fg.Position(3:4) = [560.8 409.6];
        clf

        [fg2, iFgNrNew] = addFindFigure([PlotID '-2'], iFgNrNew);
        clf
        %%

        mrk_size = 40;
        face_alpha = 0.75;
        indWest = HG_iswest(tStPredictors.Lon);
        EnvComponents = {'Month_doy', 'Depth'};
        figures = [fg, fg2];
        for j=1:length(EnvComponents)
            figure(figures(j))
            for i =DMAComponents 
                nexttile
                scatter(tStPredictors.EV(indWest, i), tStPredictors{indWest, EnvComponents{j}});
                f_Lbls(['DNA_' NS(i)], EnvComponents{j});
                title('West');
                nexttile
                scatter(tStPredictors.EV(~indWest, i), tStPredictors{~indWest, EnvComponents{j}});
                f_Lbls(['DNA_' NS(i)], EnvComponents{j});
                title('East');
            end
        end
        
    case 'PL_DM_BiodivOnDMAs'
        tStPredictors = Data.tStPredictors;
        tStMetrics = Data.tStMetrics;
        %%
         fg.Position(3:4) = [560.8 409.6];
        clf
        mrk_size = 40;
        face_alpha = 0.75;

        t = nexttile;
        s = scatter(tStPredictors.EV(:,1), tStPredictors.EV(:,2), mrk_size, tStMetrics.Richness, 'filled');
        s.MarkerFaceAlpha = face_alpha;
        colormap(t , linspecer(20));
        cb = colorbar;
        xlabel('DMA_1')
        ylabel('DMA_2')
        ylabel(cb, 'Richness (genera)');
        title('Richness');



    case 'PL_DM_Correlations'
        %plot correlations between DMA and environments and environment
        %itself
        tStPredictors = Data.tStPredictors;
        corrType = Data.corrType;
        fg.Position(3:4) = [1280.8 530];
        corrType = 'Pearson';
        fields = {'SamplingTime', 'doy', 'temp', 'Lat', 'Lon', 'salin', 'Depth', 'silicate', 'phosphate', 'nitrate', 'nitrite', 'chlorophyll_a_0'};
        [cr, rho] = corr(tStPredictors{:, fields}, tStPredictors.EV(:, 1:20), "rows","pairwise", "type",corrType)
        cr(rho > 0.001) = NaN;
        clf
        nexttile
        yLbls = fields; %{'doy', 'SamplingTime', 'Depth', 'Lon', 'Lat', 'chlorophyll-a_0', 'temp', 'cond', 'salin', 'nitrate', 'nitrite', 'silicate', 'phosphate'};
        xLbls = {'DMA_1','DMA_2','DMA_3','DMA_4','DMA_5','DMA_6','DMA_7','DMA_8','DMA_9','DMA_{10}','DMA_11','DMA_12','DMA_13','DMA_14','DMA_15','DMA_16','DMA_17','DMA_18','DMA_19','DMA_20'};
        hm = heatmap(xLbls(1:8), yLbls, cr(:, 1:8));
        hm.MissingDataColor = [1, 1, 1]*0.95;
        hm.CellLabelFormat = '%0.2g';
        colormap(redbluecmap); caxis([-0.9, 0.9]);
        title([corrType ' corr., p<0.001']);

        nexttile
        [cr, rho] = corr(tStPredictors{:, fields}, ...
            tStPredictors{:, fields}, "rows","pairwise", "type",corrType)
        cr(rho > 0.001) = NaN;
        %cr(cr==1) = NaN;
        yLbls = fields;
        xLbls =yLbls;
        hm = heatmap(xLbls, yLbls, cr(:, :));
        hm.MissingDataColor = [1, 1, 1]*0.95;
        hm.CellLabelFormat = '%0.2g';
        colormap(redbluecmap); caxis([-0.9, 0.9]);
        title([corrType ' corr., p<0.001']);
       AddLetters2Plots(fg, 'HShift', -0.075, 'VShift', -0.05)

    case 'PL_DM_345_on_DMA12'
        %plot DMA3, DMA4, DMA5 as a function of DMA1 and 2
        tStPredictors = Data.tStPredictors;

        fg.Position(3:4) = [1265.6 360.8];

        mrk_size = 10;
        face_alpha = 0.75;
        t = nexttile();
        s = scatter(tStPredictors.EV(:,1), tStPredictors.EV(:,2), mrk_size, tStPredictors.EV(:,3), 'filled');
        colormap(t , linspecer(20));
        s.MarkerFaceAlpha = face_alpha;
        f_Lbls('DMA_1', 'DMA_2');
        cb = colorbar
        title('DMA_3')

        t = nexttile();
        s = scatter(tStPredictors.EV(:,1), tStPredictors.EV(:,2), mrk_size, tStPredictors.EV(:,4), 'filled');
        colormap(t , linspecer(20));
        s.MarkerFaceAlpha = face_alpha;
        f_Lbls('DMA_1', 'DMA_2');
        cb = colorbar
        title('DMA_4')

        t = nexttile();
        s = scatter(tStPredictors.EV(:,1), tStPredictors.EV(:,2), mrk_size, tStPredictors.EV(:,5), 'filled');
        colormap(t , linspecer(20));
        s.MarkerFaceAlpha = face_alpha;
        f_Lbls('DMA_1', 'DMA_2');
        cb = colorbar
        title('DMA_5')

    case 'PL_StationNames'
        %%
        tStPredictors = Data.tStPredictors;
        tStPredictorsGrp = grpstats(tStPredictors(:, ["HGStation", "Lat", "Lon"]), "HGStation", "mean");
        fg.Position(3:4) = [844.8 390];
        clf
        s = geoscatter(tStPredictorsGrp.mean_Lat,tStPredictorsGrp.mean_Lon, 40, 'k', 'filled');
        hold on
        text(tStPredictorsGrp.mean_Lat+0.1, tStPredictorsGrp.mean_Lon,tStPredictorsGrp.HGStation);
        title('Station locations');
        geobasemap colorterrain;
    
    case 'PL_StationNames2'
        %% improved without names 
        tStPredictors = Data.tStPredictors;
        tStPredictorsGrp = grpstats(tStPredictors(:, ["HGStation", "Lat", "Lon"]), "HGStation", "mean");
        %change F4gleichSV4 to SV4
        tStPredictorsGrp.HGStation{strcmp(tStPredictorsGrp.HGStation, 'F4gleichSV4')} = 'SV4';
        %remove numbers from station names
        OldNames =  [{'EG'}    {'Grad'}    {'HG'}    {'N'}    {'S'}    {'SV'}];
        NewNames =  [{'EGC'}    {'0°'}    {'HAUSGARTEN'}    {'North'}    {'South'}    {'Svalbard'}];
        tStPredictorsGrp.HGStation = (regexprep(tStPredictorsGrp.HGStation, '\d', ''));
        fg.Position(3:4) = [1271.2 390.4];
        clf
        %make a list of unique stations 
        StationList = unique(tStPredictorsGrp.HGStation);
        clrs = lines(length(StationList)); 
        leg = cell(1, length(StationList));
        for iSt =1:length(StationList)
            ind = strcmp(StationList{iSt}, tStPredictorsGrp.HGStation);
            s = geoscatter(tStPredictorsGrp.mean_Lat(ind),tStPredictorsGrp.mean_Lon(ind),40,clrs(iSt, :), 'filled');
            hold on
            legind = strcmp(StationList{iSt}, OldNames);
            leg{legind} = NewNames{legind};
        end
        legend(leg, 'Location','northwest')

        %text(tStPredictorsGrp.mean_Lat+0.1, tStPredictorsGrp.mean_Lon,tStPredictorsGrp.HGStation);
        title('Station locations');
       
        legend
        geobasemap colorterrain;
        geolimits([77.0513883468747          80.7805373990618], [-25, 23.7539378911113]);
             
    case 'PL_StationEGCWSC'
        %% split between egc and wsc 
        tStPredictors = Data.tStPredictors;
        tStPredictorsGrp = grpstats(tStPredictors(:, ["HGStation", "Lat", "Lon"]), "HGStation", "mean");
        %change F4gleichSV4 to SV4
        tStPredictorsGrp.HGStation{strcmp(tStPredictorsGrp.HGStation, 'F4gleichSV4')} = 'SV4';
        %remove numbers from station names
        Names =  [{'EGC'}    {'WSC'}];
        tStPredictorsGrp.iswest = HG_iswest(tStPredictorsGrp.mean_Lon);
        fg.Position(3:4) = [1271.2 390.4];
        clf
        %make a list of unique stations 
        StationList = [1, 0];
        clrs = lines(length(StationList)); 
        leg = cell(1, length(StationList));
        for iSt =1:length(StationList)
            ind = tStPredictorsGrp.iswest == StationList(iSt);
            s = geoscatter(tStPredictorsGrp.mean_Lat(ind),tStPredictorsGrp.mean_Lon(ind),100,clrs(iSt, :), 'filled', 'MarkerEdgeColor', 'k');
            hold on
            leg{iSt} = Names{iSt};
        end
        legend(leg, 'Location','northwest')

        %text(tStPredictorsGrp.mean_Lat+0.1, tStPredictorsGrp.mean_Lon,tStPredictorsGrp.HGStation);
        title('Station locations');
       
        legend
        geobasemap colorterrain;
        geolimits([77.0513883468747          80.7805373990618], [-25, 23.7539378911113]);
   
    case 'PL_DM_CharComm'
        %% find main species groups over dm components
        tTraits = Data.tTraits;
        tStPredictors = Data.tStPredictors;
        clstr_id = tStPredictors.clstr_id;
        K = tStPredictors.Properties.UserData.clstr.K;
        V_mat = Data.V_mat;
        clrs = distinguishable_colors(K);
        %make K clusters of data in duffusion map based on first 4
        %components
        %          clf
        %          for K = 2:12
        %              [idx, C] = kmeans(tStPredictors.EV(:, 1:4), K,  "Replicates", 10);
        %              s = silhouette(tStPredictors.EV(:, 1:4),idx);
        %              plot(K, mean(s), 'o');
        %              hold on
        %          end
        %%silhouete analysis shows that K=7 is the best number of


        fg.Position(3:4) = [ 1624 1019];
        clf
        %plot clusters in the first two coordinates
        nexttile(1)
        %for each cluster find average abundance of species
        sp_comp_avg = grpstats(V_mat', clstr_id)';
        sp_comp_avg = array2table(sp_comp_avg);
        grp_by = {'Class', 'Order', 'Family', 'Genus'};
        lvl_count = length(grp_by);
        tiledlayout(lvl_count, K, "TileSpacing","tight", "Padding","tight");
        for iGr = 1:lvl_count
            %group this abuandances by Phylum/Class/Order/Family
            level = grp_by{iGr};
            %find total sum by groups
            sp_comp_avg_lvl = [sp_comp_avg, tTraits(:, level)];
            sp_comp_avg_lvl = grpstats(sp_comp_avg_lvl, level, 'sum');
            for iCl =1:K %for each cluster make a bar plot
                %take a coloumn corresponding to cluster iCl
                abnd = sp_comp_avg_lvl.(['sum_sp_comp_avg' NS(iCl)]);
                lbls = sp_comp_avg_lvl.(level);
                %select 5 most abuandant
                k_max = 7;
                [B,I] = maxk(abnd, k_max);
                %make a bar plot
                ax = nexttile(iCl + (iGr-1)*K);
                b = bar(B);
                b.FaceColor = clrs(iCl, :);
                ax.XTickLabel = string(lbls(I)');
                if iCl == 1
                    ylabel(level);
                end
            end
        end
    case 'PL_DM_EV1-doy-year'
        %% plot the dependence on EV1, day of year and year as a color to see which year lead to wrong commuinities 
        tStPredictors = Data.tStPredictors;
        %%
        fg.Position(3:4) = [ 1624 1019];
        clf
        nexttile
        face_alpha = 0.5;
        s = scatter(tStPredictors.EV(:, 1), tStPredictors.Month_doy, 50, tStPredictors.Year, "filled" )
        xlabel('Diff map, ax 1');
        ylabel('Day of year');
        Years = unique(tStPredictors.Year);
        colormap(gca , linspecer(length(Years)));
        %colormap(gca, distinguishable_colors(Years(end)-Years(1)+1 ));
        caxis([Years(1) - 0.5, Years(end) + 0.5 ]);
        s.MarkerFaceAlpha = face_alpha;
        f_Lbls('DMA 1', 'Day of year') ;
        cb = colorbar;
        %lm = fitlm(tStPredictors.EV(:, 1), tStPredictors.Month_doy);
        [Slope, Intercept] = wols_line(tStPredictors.EV(:, 1), tStPredictors.Month_doy);
        hold on
        evAx = -1:0.1:1;
        plot(evAx, Slope*evAx + Intercept, "Color", 'k', "LineWidth",3);

        nexttile
        s = scatter(tStPredictors.EV(:, 1), tStPredictors.Month_doy, 50, tStPredictors.Depth, "filled" )
        colormap(gca , linspecer(20));
        caxis([0, (80)]);
        s.MarkerFaceAlpha = face_alpha;
        f_Lbls('DMA 1', 'Day of year') ;
        cb = colorbar;
        title('Depth');

        nexttile
        s = scatter(tStPredictors.EV(:, 1), tStPredictors.Month_doy, 50, tStPredictors.Lon, "filled" )
        colormap(gca , linspecer(20));
        s.MarkerFaceAlpha = face_alpha;
        f_Lbls('DMA 1', 'Day of year') ;
        cb = colorbar;
        title('Longitude');

        nexttile
        %Month_doy = a + b * dm1; -> (Month_doy - a)/b =  dm1;
        s = scatter(tStPredictors.Year + tStPredictors.Month_doy/365 + (0.5*(rand(size(tStPredictors, 1), 1) - 0.5)), tStPredictors.EV(:, 1) - (tStPredictors.Month_doy - Intercept)/Slope, 50,  tStPredictors.Lon, 'filled') 
        colormap(gca , linspecer(20));
        s.MarkerFaceAlpha = face_alpha;
        f_Lbls('Year', 'Comm shift') ;
        cb = colorbar;
        title('Longitude');

        nexttile
        %Month_doy = a + b * dm1; -> (Month_doy - a)/b =  dm1;
        s = scatter(tStPredictors.Year + tStPredictors.Month_doy/365 + (0.5*(rand(size(tStPredictors, 1), 1) - 0.5)), tStPredictors.EV(:, 1) - (tStPredictors.Month_doy - Intercept)/Slope, 50,  tStPredictors.Lat, 'filled') 
        colormap(gca , linspecer(20));
        s.MarkerFaceAlpha = face_alpha;
        f_Lbls('Year', 'Comm shift') ;
        cb = colorbar;
        title('Lat');


        fg = findobj( 'Type', 'Figure', 'Name', [PlotID '_split']);
        if isempty(fg)
            fg = figure(iFgNrNew);
            fg.Name = [PlotID '_split'];
        else
            figure(fg);
        end
        iFgNrNew = iFgNrNew + 1;
%%
        clf
        indW = tStPredictors.Lon < 0;
        indC = tStPredictors.Lon >= 0 & tStPredictors.Lon < 6.5;
        indE = tStPredictors.Lon >= 0 & tStPredictors.Lon > 6.5;
        inds = {indW, indC, indE};
        titles = {'West', 'Center', 'East'};
        for i = 1:length(inds)
            nexttile
            cla
            ind = inds{i};
            face_alpha = 0.5;
            s = scatter(tStPredictors.EV(ind, 1), tStPredictors.Month_doy(ind), 50, tStPredictors.Year(ind), "filled" )
            xlabel('Diff map, ax 1');
            ylabel('Day of year');
            %colormap(gca , linspecer(length(Years)));
            colormap(gca, distinguishable_colors(Years(end)-Years(1)+1 ));
            caxis([Years(1) - 0.5, Years(end) + 0.5 ]);
            s.MarkerFaceAlpha = face_alpha;
            f_Lbls('DMA 1', 'Day of year') ;
            cb = colorbar;
            title(titles{i})

            %add line for selecting outliyers
            switch titles{i} 
                case 'West' 
                    hold on 
                    x0 = 0.4; % from histogram(tStPredictors.EV(ind, 1), 40) there is a tail in the range tStPredictors.EV(ind, 1)<x0 
                    ind2Save = ind & tStPredictors.EV(:, 1) < x0;
                    plot([x0, x0], [6, 9], 'k', 'LineWidth', 2);
                case {'Center', 'East'}
                    hold on 
                    evAx =  tStPredictors.EV(:, 1);
                    [~, evAxOrder] = sort(evAx);
                    delta = 1.2;
                    yMin = Slope*evAx + Intercept-0.2 - delta;
                    yMax = Slope*evAx + Intercept-0.2 + delta;
                    plot(evAx(evAxOrder), yMin(evAxOrder), "Color", 'k', "LineWidth",3);
                    plot(evAx(evAxOrder), yMax(evAxOrder), "Color", 'k', "LineWidth",3);
                    ind2Save = ind & (tStPredictors.Month_doy < yMin | tStPredictors.Month_doy > yMax);
                   % plot([x0, x0], [6, 9], 'k', 'LineWidth', 2);
            end 
            %mark outliers
            scatter(tStPredictors.EV(ind2Save, 1), tStPredictors.Month_doy(ind2Save), 50, 'k');
            %save outliers
            HGP = HG_GetParams;
            writenewtable(tStPredictors(ind2Save, :), [HGP.Data.Path2CalcData 'Outliers_' titles{i} '.xlsx']);


            nexttile
            ind = inds{i};
            face_alpha = 0.5;
            s = scatter(tStPredictors.EV(ind, 1), tStPredictors.Month_doy(ind), 50, tStPredictors.Depth(ind), "filled" )
            xlabel('Diff map, ax 1');
            ylabel('Day of year');
            colormap(gca , linspecer(length(Years)));
           % colormap(gca, distinguishable_colors(Years(end)-Years(1)+1 ));
             caxis([0, (80)]);
            s.MarkerFaceAlpha = face_alpha;
            f_Lbls('DMA 1', 'Day of year') ;
            cb = colorbar;
            title(titles{i})


        end


    case {'PL_DM_Depth_Month_Year', 'PL_DM_Depth_Month_Long', 'PL_DM_Depth_Month_Long_Clstr', 'PL_DM_Depth_Month_YearR'}
        %plot diffusion map with depth, month and year as drivers
        tStPredictors = Data.tStPredictors;
        mrk_size = 10;
        face_alpha = 0.75;

        %% Diffusion map and depth, month, year
        fg02 = fg;
        fg02.Position(3:4) = [930.4 793.6];
        clf
        t = nexttile(1);
        s = scatter(tStPredictors.EV(:,1), tStPredictors.EV(:,2), mrk_size, tStPredictors.EV(:,3), 'filled');
        colormap(t , linspecer(20));
        s.MarkerFaceAlpha = face_alpha;
        f_Lbls('i-trait_1', 'i-trait_2');
        cb = colorbar
        ylabel(cb, 'i-trait_3');
        title('Diffusion map')


        t = nexttile(2)
        s = scatter(tStPredictors.EV(:,1), tStPredictors.EV(:,2), mrk_size, (tStPredictors.Depth), 'filled');
        colormap(t , linspecer(20));
        %set(gca,'ColorScale','log');
        s.MarkerFaceAlpha = face_alpha;
        caxis([0, (80)]);
        f_Lbls('i-trait_1', 'i-trait_2') ;
        cb = colorbar;
        ylabel(cb, 'Depth');
        title('Depth')

        t = nexttile(3);
        s = scatter(tStPredictors.EV(:,1), tStPredictors.EV(:,2), mrk_size, tStPredictors.MonthNum, 'filled');
        Months = unique(tStPredictors.MonthNum);
        %clrs = distinguishable_colors(Months(end)-Months(1)+1 +1); colormap(t, clrs(1:end-1, :));
        %clrs = parula(Months(end)-Months(1)+1); colormap(t, clrs);
        clrs = jet(Months(end)-Months(1)+1); colormap(t, clrs);
        caxis([Months(1) - 0.5, Months(end) + 0.5 ]);
        s.MarkerFaceAlpha = face_alpha;
        f_Lbls('i-trait_1', 'i-trait_2') ;
        cb = colorbar;
        ylabel(cb, 'Month');
        title('Month')

        t = nexttile(4);
        s = scatter(tStPredictors.EV(:,1), tStPredictors.EV(:,2), mrk_size, tStPredictors.Year, 'filled');
        Years = unique(tStPredictors.Year);
        colormap(t, distinguishable_colors(Years(end)-Years(1)+1 ));
        caxis([Years(1) - 0.5, Years(end) + 0.5 ]);
        s.MarkerFaceAlpha = face_alpha;
        f_Lbls('i-trait_1', 'i-trait_2') ;
        cb = colorbar;
        ylabel(cb, 'Year');
        title('Year');


        t = nexttile(5);
        s = scatter(tStPredictors.EV(:,1), tStPredictors.EV(:,2), mrk_size, tStPredictors.Month_doy, 'filled');
        colormap(t , linspecer(20));
        caxis([5.5, 11]);
        s.MarkerFaceAlpha = face_alpha;
        f_Lbls('i-trait_1', 'i-trait_2') ;
        cb = colorbar;
        ylabel(cb, 'Month_doy');
        title('Month_doy');
        

        if any(strcmp(PlotID, {'PL_DM_Depth_Month_Long', 'PL_DM_Depth_Month_Long_Clstr'}))
            %plot dependence on longitude
            t = nexttile;
            s = scatter(tStPredictors.EV(:,1), tStPredictors.EV(:,2), mrk_size, tStPredictors.Lon, 'filled');
            colormap(t , linspecer(20));
            s.MarkerFaceAlpha = face_alpha;
            %caxis([0, (80)]);
            f_Lbls('i-trait_1', 'i-trait_3') ;
            cb = colorbar;
            ylabel(cb, 'Longitude');
            title('Longitude')
        end

        if (strcmp(PlotID, {'PL_DM_Depth_Month_Long_Clstr'}))
            %plot clusters
            t = nexttile;
            cla
            C =  tStPredictors.Properties.UserData.clstr.C;
            K =  tStPredictors.Properties.UserData.clstr.K;
            clrs = distinguishable_colors(K);
            s = scatter(tStPredictors.EV(:,1), tStPredictors.EV(:,2), mrk_size, tStPredictors.clstr_id, 'filled');
            %gscatter(tStPredictors.EV(:, 1), tStPredictors.EV(:, 2), clstr_id, clrs)
            colormap(t, clrs);
            s.MarkerFaceAlpha = face_alpha;
            hold on
            gscatter(C(:, 1), C(:, 2), 1:K, clrs, 'o', 5, 'filled', "")
            legend("hide");
            f_Lbls('i-trait_1', 'i-trait_2') ;
            cb = colorbar;
            caxis([0.5, K + 0.5 ]);
            cb.Ticks = 1:K;
            ylabel(cb, 'Cluster ID');
            title('Cluster ID')
        end

        %make a 3d plots colored with day of year and depth 
        t = nexttile;
        s = scatter3(tStPredictors.EV(:,1), tStPredictors.EV(:,2), tStPredictors.EV(:,3), mrk_size, tStPredictors.Month_doy, 'filled');
        colormap(t , linspecer(20));
        caxis([5.5, 11]);
        s.MarkerFaceAlpha = face_alpha;
        f_Lbls3D('i-trait_1', 'i-trait_2', 'i-trait_3') ;
        cb = colorbar;
        ylabel(cb, 'Month_doy');
        title('Month_doy');

         t = nexttile
        s = scatter3(tStPredictors.EV(:,1), tStPredictors.EV(:,2), ... 
            tStPredictors.EV(:, 3), mrk_size, (tStPredictors.Depth), 'filled');
        colormap(t , linspecer(20));
        s.MarkerFaceAlpha = face_alpha;
        caxis([0, (80)]);
        f_Lbls3D('i-trait_1', 'i-trait_2', 'i-trait_3') ;
        cb = colorbar;
        ylabel(cb, 'Depth');
        title('Depth')


        AddLetters2Plots(fg02);



        %% Add a supplimentary figure with splitting west and east stations
        PlotID2 = [PlotID 'suppDOY'];
        [fg, iFgNrNew] = addFindFigure(PlotID2, iFgNrNew);
        fg.Position(3:4) = [1000 536];
        ax_lims = [-1.3, 1, -0.75, 0.75];
        figure(fg)
        clf
        nexttile;
        s = scatter(tStPredictors.EV(:,1), tStPredictors.EV(:,2), mrk_size, tStPredictors.Month_doy, 'filled');
        colormap(linspecer(20));
        caxis([5.5, 11]);
        s.MarkerFaceAlpha = face_alpha;
        f_Lbls('DMA_1', 'DMA_2') ;
        cb = colorbar;
        ylabel(cb, 'Month');
        axis(ax_lims)
        title('All');

        indWest = tStPredictors.Lon <= 0;
        nexttile;
        s = scatter(tStPredictors.EV(indWest,1), tStPredictors.EV(indWest,2), mrk_size, tStPredictors.Month_doy(indWest), 'filled');
        colormap(linspecer(20));
        caxis([5.5, 11]);
        s.MarkerFaceAlpha = face_alpha;
        f_Lbls('DMA_1', 'DMA_2') ;
        cb = colorbar;
        ylabel(cb, 'Month');
        title('Lat \leq 0\circ');
        axis(ax_lims)
        nexttile;
        s = scatter(tStPredictors.EV(~indWest,1), tStPredictors.EV(~indWest,2), mrk_size, tStPredictors.Month_doy(~indWest), 'filled');
        colormap(t , linspecer(20));
        caxis([5.5, 11]);
        s.MarkerFaceAlpha = face_alpha;
        f_Lbls('DMA_1', 'DMA_2') ;
        cb = colorbar;
        title('Lat > 0\circ');
        axis(ax_lims)

        nexttile;
        s = scatter(tStPredictors.EV(:,1), tStPredictors.EV(:,2), mrk_size, tStPredictors.Depth, 'filled');
        colormap(linspecer(20));
        caxis([0, (80)]);
        s.MarkerFaceAlpha = face_alpha;
        f_Lbls('DMA_1', 'DMA_2') ;
        cb = colorbar;
        ylabel(cb, 'Depth');
        axis(ax_lims)
        title('All');

        indWest = tStPredictors.Lon <= 0;
        nexttile;
        s = scatter(tStPredictors.EV(indWest,1), tStPredictors.EV(indWest,2), mrk_size, tStPredictors.Depth(indWest), 'filled');
        colormap(linspecer(20));
         caxis([0, (80)]);
        s.MarkerFaceAlpha = face_alpha;
        f_Lbls('DMA_1', 'DMA_2') ;
        cb = colorbar;
        ylabel(cb, 'Depth');
        title('Lat \leq 0\circ');
        axis(ax_lims)
        nexttile;
        s = scatter(tStPredictors.EV(~indWest,1), tStPredictors.EV(~indWest,2), mrk_size, tStPredictors.Depth(~indWest), 'filled');
        colormap(t , linspecer(20));
        caxis([0, (80)]);
        s.MarkerFaceAlpha = face_alpha;
        f_Lbls('DMA_1', 'DMA_2') ;
        cb = colorbar;
        title('Lat > 0\circ');
        axis(ax_lims)
        
        AddLetters2Plots(fg);


        PlotID3 = [PlotID 'suppDOY_all'];
        [fg, iFgNrNew] = addFindFigure(PlotID3, iFgNrNew);
        fg.Position(3:4) = [1.0076e+03 251];
        ax_lims = [-1.3, 1, -0.75, 0.75];
        figure(fg)
        clf

        nexttile;
        s = scatter(tStPredictors.EV(:,1), tStPredictors.EV(:,2), mrk_size, tStPredictors.EV(:,3), 'filled');
        colormap(linspecer(20));
        %caxis([5.5, 11]);
        s.MarkerFaceAlpha = face_alpha;
        f_Lbls('DMA_1', 'DMA_2') ;
        cb = colorbar;
        ylabel(cb, 'DMA_3');
        axis(ax_lims)
        title('DMA_3');
  
        nexttile;
        s = scatter(tStPredictors.EV(:,1), tStPredictors.EV(:,2), mrk_size, tStPredictors.Month_doy, 'filled');
        colormap(linspecer(20));
        caxis([5.5, 11]);
        s.MarkerFaceAlpha = face_alpha;
        f_Lbls('DMA_1', 'DMA_2') ;
        cb = colorbar;
        ylabel(cb, 'Month');
        axis(ax_lims)
        title('Month');

  
        nexttile;
        s = scatter(tStPredictors.EV(:,1), tStPredictors.EV(:,2), mrk_size, tStPredictors.Depth, 'filled');
        colormap(linspecer(20));
        caxis([0, (80)]);
        s.MarkerFaceAlpha = face_alpha;
        f_Lbls('DMA_1', 'DMA_2') ;
        cb = colorbar;
        ylabel(cb, 'Depth');
        axis(ax_lims)
        title('Depth');

        AddLetters2Plots(fg);        
    otherwise
        error('Plot not defined in DiffMaps_Adds_Others')
end

