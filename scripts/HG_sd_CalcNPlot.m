function [iFgNrNew, Results] =  HG_sd_CalcNPlot(PlotID, Data, iFgNr)
%Plot figures for HG_sd_
arguments
    PlotID
    Data
    iFgNr = -1; %figure will not be created
end

[fg, iFgNrNew] = addFindFigure(PlotID, iFgNr);

switch PlotID
    case 'plotSummerCruises'
        tStPredictors = Data.tStPredictors;
        %select summer months
        tStPredictors = tStPredictors(tStPredictors.MonthNum>=6 & tStPredictors.MonthNum<=7, :);
        %select summer months
        inds = [0, 1];  %west or east
        for i = 1:length(inds)
            indWE = tStPredictors.indEast == inds(i);
            nexttile
            f_fitplotLinearRegression(tStPredictors.Year(indWE), tStPredictors.Month_doy(indWE), [],  [0, 0, 0]);
            f_Lbls('Year', 'Month');
        end


    case 'PlotSummerCorrelations'
        % plot correlations of chl and T with Richness
        tStPredictors = Data.tStPredictors;
        tTraits = Data.tTraits;
        meanFamAbundSmpl = Data.meanFamAbundSmpl;

        %Filter summer data
        indSelectedSamples = tStPredictors.MonthNum>=6 & tStPredictors.MonthNum<=7;
        tStPredictors = tStPredictors(indSelectedSamples, :);
        meanFamAbundSmpl = meanFamAbundSmpl(indSelectedSamples, :);

        grpstats(tStPredictors(:, {'indDepth', 'indEast'}), {'indDepth', 'indEast'})
        %         indDepth    indEast    GroupCount
        % 0_0     false       false         43
        % 0_1     false       true         167
        % 1_0     true        false         36
        % 1_1     true        true         217

        tStPredictors.ESN = f_DiversityMetrics(meanFamAbundSmpl(:,:), [], 'SimpsonESN', [], 2)';
        tStPredictors.Richness = f_DiversityMetrics(meanFamAbundSmpl(:,:), [], 'Richness', [], 2)';


        fg.Position(3:4) = [  833.6        641.6];

 


        %%
        Drivers = {'temp'};
        Drivers_eq = {'t°'};
        Drivers_label = {'Temperature'};

        LabelNames = ["EGC,S", "EGC,D", "WSC,S", "WSC,D"];
        indCombinations = [ 0, 0; 0, 1; 1, 0; 1, 1];  %E/W; Shallow/Deep
        clf
        t = tiledlayout('flow');
        t.TileIndexing = 'columnmajor';
        clr = lines(1);
         mdls = {};
        for iInds = 1:height(indCombinations )
            for iDrv = 1:length(Drivers)
                nexttile
                ind = (tStPredictors.indDepth == indCombinations(iInds, 2) & tStPredictors.indEast == indCombinations(iInds, 1));
                x = tStPredictors{ind, Drivers{iDrv}};
                y = tStPredictors{ind, 'Richness'};
                mdl = plot_fit_CI(x, y, 60, clr, 0.75);
                mdls{end+1} = mdl;
                f_Lbls(Drivers_label{iDrv}, 'Richness');
                p = mdl.Coefficients.pValue(2);
                %slope and intercept
                in = mdl.Coefficients.Estimate(1);
                sl = mdl.Coefficients.Estimate(2);

                if p <0.05
                    title(sprintf('%s:  slope=%.2f, R^2=%1.g', LabelNames{iInds}, sl,  mdl.Rsquared.Ordinary))
                else
                    title(sprintf('%s: n.s., R^2=%1.g', LabelNames{iInds},  mdl.Rsquared.Ordinary))
                end
            end
            % nexttile
            % ind = (tStPredictors.indDepth == indCombinations(iInds, 2) & tStPredictors.indEast == indCombinations(iInds, 1));
            % x = tStPredictors{ind, Drivers{1}};
            % y = tStPredictors{ind, Drivers{2}};
            % mdl = plot_fit_CI(x, y, 60, clr, 0.5);
            % f_Lbls(Drivers_label{1}, Drivers_label{2});
            % p = mdl.Coefficients.pValue(2);
            % sl = mdl.Coefficients.Estimate(2);
            % if p <0.05
            %     title(sprintf('%s: %s~%.1f*%s, p=%1.e', LabelNames{iInds}, Drivers_eq{2}, sl, Drivers_eq{1}, p))
            % else
            %     title(LabelNames{iInds})
            % end
        end

        AddLetters2Plots('HShift', -0.08, 'VShift', -0.04, 'Location', 'NorthWest')


        %% plot chl and T as a function of the year

      
%%
        Drivers = {'temp', 'chlorophyll_a_0'};
        Drivers_eq = {'t°', 'Chl-a'};
        Drivers_label = {'Temperature', 'Chl-a, \mug/L'};
        Drivers_transpow = [1, 0.25];
        [fg2, iFgNrNew] = addFindFigure([PlotID 'chl-T_year'], iFgNrNew);
        fg2.Position(3:4) = [1000 680];
        tiledlayout("vertical")
        clf
        clrs = lines(4);
        mdls = {};
        for iDrv = 1:length(Drivers)
            splots = [];
            leg = {};
            nexttile
            for iInds = 1:height(indCombinations )
                ind = (tStPredictors.indDepth == indCombinations(iInds, 2) & tStPredictors.indEast == indCombinations(iInds, 1));
                rndOffSet = 0.1*(rand(sum(ind), 1)-0.5)*0.5+ ((iInds-2)*0.2-0.1)*0.5;
                x = tStPredictors.Year(ind) + rndOffSet;
                %x = tStPredictors.Year(ind) + (tStPredictors.Month_doy(ind)-1)/12 + (iInds-2)*0.2-0.1;
                y = tStPredictors{ind, Drivers{iDrv}};
                [mdl, s] = plot_fit_CI(x, y, 30, clrs(iInds, :), 0.5, clrs(iInds, :), 'o', Drivers_transpow(iDrv));
                %f_plotResidualsmy(mdl);
                splots(end+1) = s;
                f_Lbls('Year', Drivers_label{iDrv});
                p = mdl.Coefficients.pValue(2);
                sl = mdl.Coefficients.Estimate(2);
                mdls{end+1} = mdl;
                hold on
                if p <0.05
                    leg{end+1}=sprintf('%s: slope=%.2f, R^2=%1.g', LabelNames{iInds}, sl,  mdl.Rsquared.Ordinary);
                else
                    leg{end+1}=sprintf('%s', LabelNames{iInds});
                    %title(LabelNames{iInds})
                end
            end
            legend(splots, leg, 'Location', 'best');
            xlim([2008.5, 2021.5])
            ax = gca;
            ax.XTick = [2009:2021];
        end
        AddLetters2Plots('HShift', -0.08, 'VShift', -0.04, 'Location', 'NorthWest')
        %% find mean temperature in EGC and WSC
        WSCTemp = tStPredictors.temp(tStPredictors.indEast == 1);
        Results.Temp.WSCMean = nanmean(WSCTemp );
        Results.Temp.WSCSE =  nanstd(WSCTemp )/sqrt(sum(~isnan(WSCTemp )));

        EGCTemp = tStPredictors.temp(tStPredictors.indEast == 0);
        Results.Temp.EGCMean = nanmean(EGCTemp );
        Results.Temp.EGCSE =  nanstd(EGCTemp )/sqrt(sum(~isnan(EGCTemp )));

        %% plot chl vs T

        Drivers = {'temp', 'chlorophyll_a_0'};
        Drivers_eq = {'t°', 'Chl-a'};
        Drivers_label = {'Temperature', 'Chl-a, \mug/L'};

        [fg2, iFgNrNew] = addFindFigure([PlotID 'chl-T'], iFgNrNew);
        fg2.Position(3:4) = [1000 680];
        t = tiledlayout('flow');
        t.TileIndexing = 'columnmajor';
        leg = {};
        mdls = {};
        for iInds = 1:height(indCombinations )
            nexttile
            ind = (tStPredictors.indDepth == indCombinations(iInds, 2) & tStPredictors.indEast == indCombinations(iInds, 1));
            x = tStPredictors{ind, Drivers{1}};
            y = tStPredictors{ind, Drivers{2}};


            mdl = plot_fit_CI(x, y, 60, clr, 0.75, 'k', 'o', 0.25);
            mdls{end+1} = mdl;
            %f_plotResidualsmy(mdl)
            f_Lbls(Drivers_label{1}, Drivers_label{2});
            p = mdl.Coefficients.pValue(2);
            %slope and intercept
            in = mdl.Coefficients.Estimate(1);
            sl = mdl.Coefficients.Estimate(2);
            if p <0.05
                title(sprintf('%s:  slope=%.2f, R^2=%1.g', LabelNames{iInds}, sl,  mdl.Rsquared.Ordinary))
            else
                title(sprintf('%s: n.s., R^2=%1.g', LabelNames{iInds},  mdl.Rsquared.Ordinary))
            end

        end
        AddLetters2Plots('HShift', -0.08, 'VShift', -0.04, 'Location', 'NorthWest')
        %%



    case 'PlotRichnessOnTSummer'
        % plot correlations of chl and T with Richness
        tStPredictors = Data.tStPredictors;
        tTraits = Data.tTraits;
        meanFamAbundSmpl = Data.meanFamAbundSmpl;

        %Filter summer data
        indSelectedSamples = tStPredictors.MonthNum>=6 & tStPredictors.MonthNum<=7;
        tStPredictors = tStPredictors(indSelectedSamples, :);
        meanFamAbundSmpl = meanFamAbundSmpl(indSelectedSamples, :);

        grpstats(tStPredictors(:, {'indDepth', 'indEast'}), {'indDepth', 'indEast'})
        %         indDepth    indEast    GroupCount
        % 0_0     false       false         43
        % 0_1     false       true         167
        % 1_0     true        false         36
        % 1_1     true        true         217

        tStPredictors.ESN = f_DiversityMetrics(meanFamAbundSmpl(:,:), [], 'SimpsonESN', [], 2)';
        tStPredictors.Richness = f_DiversityMetrics(meanFamAbundSmpl(:,:), [], 'Richness', [], 2)';


        fg.Position(3:4) = [  833.6        641.6];

 


        %%
        Drivers = {'temp'};
        Drivers_eq = {'t°'};
        Drivers_label = {'Temperature'};

        LabelNames = ["EGC,S", "EGC,D", "WSC,S", "WSC,D"];
        indCombinations = [ 0, 0; 0, 1; 1, 0; 1, 1];  %E/W; Shallow/Deep
        clf
        t = tiledlayout('flow');
        t.TileIndexing = 'columnmajor';
        clr = lines(1);
         mdls = {};
        for iInds = 1:height(indCombinations )
            for iDrv = 1:length(Drivers)
                nexttile
                ind = (tStPredictors.indDepth == indCombinations(iInds, 2) & tStPredictors.indEast == indCombinations(iInds, 1));
                x = tStPredictors{ind, Drivers{iDrv}};
                y = tStPredictors{ind, 'Richness'};
                mdl = plot_fit_CI(x, y, 60, clr, 0.75);
                mdls{end+1} = mdl;
                f_Lbls(Drivers_label{iDrv}, 'Richness');
                p = mdl.Coefficients.pValue(2);
                %slope and intercept
                in = mdl.Coefficients.Estimate(1);
                sl = mdl.Coefficients.Estimate(2);

                if p <0.05
                    title(sprintf('%s:  slope=%.2f, R^2=%1.g', LabelNames{iInds}, sl,  mdl.Rsquared.Ordinary))
                else
                    title(sprintf('%s: n.s., R^2=%1.g', LabelNames{iInds},  mdl.Rsquared.Ordinary))
                end
            end
            % nexttile
            % ind = (tStPredictors.indDepth == indCombinations(iInds, 2) & tStPredictors.indEast == indCombinations(iInds, 1));
            % x = tStPredictors{ind, Drivers{1}};
            % y = tStPredictors{ind, Drivers{2}};
            % mdl = plot_fit_CI(x, y, 60, clr, 0.5);
            % f_Lbls(Drivers_label{1}, Drivers_label{2});
            % p = mdl.Coefficients.pValue(2);
            % sl = mdl.Coefficients.Estimate(2);
            % if p <0.05
            %     title(sprintf('%s: %s~%.1f*%s, p=%1.e', LabelNames{iInds}, Drivers_eq{2}, sl, Drivers_eq{1}, p))
            % else
            %     title(LabelNames{iInds})
            % end
        end

        AddLetters2Plots('HShift', -0.08, 'VShift', -0.04, 'Location', 'NorthWest')


        %% plot chl and T as a function of the year

      
%%
        Drivers = {'temp', 'chlorophyll_a_0'};
        Drivers_eq = {'t°', 'Chl-a'};
        Drivers_label = {'Temperature', 'Chl-a, \mug/L'};
        Drivers_transpow = [1, 0.25];
        [fg2, iFgNrNew] = addFindFigure([PlotID 'chl-T_year'], iFgNrNew);
        fg2.Position(3:4) = [1000 680];
        tiledlayout("vertical")
        clf
        clrs = lines(4);
        mdls = {};
        for iDrv = 1:length(Drivers)
            splots = [];
            leg = {};
            nexttile
            for iInds = 1:height(indCombinations )
                ind = (tStPredictors.indDepth == indCombinations(iInds, 2) & tStPredictors.indEast == indCombinations(iInds, 1));
                x = tStPredictors.Year(ind) + (tStPredictors.Month_doy(ind)-1)/12 + (iInds-2)*0.2-0.1;
                y = tStPredictors{ind, Drivers{iDrv}};
                [mdl, s] = plot_fit_CI(x, y, 30, clrs(iInds, :), 0.5, clrs(iInds, :), 'o', Drivers_transpow(iDrv));
                %f_plotResidualsmy(mdl);
                splots(end+1) = s;
                f_Lbls('Year', Drivers_label{iDrv});
                p = mdl.Coefficients.pValue(2);
                sl = mdl.Coefficients.Estimate(2);
                mdls{end+1} = mdl;
                hold on
                if p <0.05
                    leg{end+1}=sprintf('%s: slope=%.2f, R^2=%1.g', LabelNames{iInds}, sl,  mdl.Rsquared.Ordinary);
                else
                    leg{end+1}=sprintf('%s', LabelNames{iInds});
                    %title(LabelNames{iInds})
                end
            end
            legend(splots, leg, 'Location', 'best');
            xlim([2009, 2022])
            ax = gca;
            ax.XTick = [2009:2022];
        end
        AddLetters2Plots('HShift', -0.08, 'VShift', -0.04, 'Location', 'NorthWest')
        %% find mean temperature in EGC and WSC in summer months
        indSelectedSamples = tStPredictors.MonthNum>=6 & tStPredictors.MonthNum<=7;
        WSCTemp = tStPredictors.temp(tStPredictors.indEast == 1&indSelectedSamples);
        Results.Temp.WSCMean = nanmean(WSCTemp );
        Results.Temp.WSCSE =  nanstd(WSCTemp )/sqrt(sum(~isnan(WSCTemp )));

        EGCTemp = tStPredictors.temp(tStPredictors.indEast == 0&indSelectedSamples);
        Results.Temp.EGCMean = nanmean(EGCTemp );
        Results.Temp.EGCSE =  nanstd(EGCTemp )/sqrt(sum(~isnan(EGCTemp )));

        %% plot chl vs T

        Drivers = {'temp', 'chlorophyll_a_0'};
        Drivers_eq = {'t°', 'Chl-a'};
        Drivers_label = {'Temperature', 'Chl-a, \mug/L'};

        [fg3, iFgNrNew] = addFindFigure([PlotID 'chl-T'], iFgNrNew);
        fg3.Position(3:4) = [1000 680];
        t = tiledlayout('flow');
        t.TileIndexing = 'columnmajor';
        leg = {};
        mdls = {};
        for iInds = 1:height(indCombinations )
            nexttile
            ind = (tStPredictors.indDepth == indCombinations(iInds, 2) & tStPredictors.indEast == indCombinations(iInds, 1));
            x = tStPredictors{ind, Drivers{1}};
            y = tStPredictors{ind, Drivers{2}};


            mdl = plot_fit_CI(x, y, 60, clr, 0.75, 'k', 'o', 0.25);
            mdls{end+1} = mdl;
            %f_plotResidualsmy(mdl)
            f_Lbls(Drivers_label{1}, Drivers_label{2});
            p = mdl.Coefficients.pValue(2);
            %slope and intercept
            in = mdl.Coefficients.Estimate(1);
            sl = mdl.Coefficients.Estimate(2);
            if p <0.05
                title(sprintf('%s:  slope=%.2f, R^2=%1.g', LabelNames{iInds}, sl,  mdl.Rsquared.Ordinary))
            else
                title(sprintf('%s: n.s., R^2=%1.g', LabelNames{iInds},  mdl.Rsquared.Ordinary))
            end

        end
        AddLetters2Plots('HShift', -0.08, 'VShift', -0.04, 'Location', 'NorthWest')
        %%


    case 'PlotRichnessOnT'
        % plot richness and diversity vs chl and T 
        % tStPredictors = Data.tStPredictors;
        tTraits = Data.tTraits;
        meanFamAbundSmpl = Data.meanFamAbundSmpl;

        %Filter summer data
        indSelectedSamples = tStPredictors.MonthNum>=6 & tStPredictors.MonthNum<=7;
        tStPredictors = tStPredictors(indSelectedSamples, :);
        meanFamAbundSmpl = meanFamAbundSmpl(indSelectedSamples, :);

        grpstats(tStPredictors(:, {'indDepth', 'indEast'}), {'indDepth', 'indEast'})
        %         indDepth    indEast    GroupCount
        % 0_0     false       false         43
        % 0_1     false       true         167
        % 1_0     true        false         36
        % 1_1     true        true         217

        tStPredictors.ESN = f_DiversityMetrics(meanFamAbundSmpl(:,:), [], 'SimpsonESN', [], 2)';
        tStPredictors.Richness = f_DiversityMetrics(meanFamAbundSmpl(:,:), [], 'Richness', [], 2)';


        fg.Position(3:4) = [  833.6        641.6];

 


        %%
        Drivers = {'temp'};
        Drivers_eq = {'t°'};
        Drivers_label = {'Temperature'};

        LabelNames = ["EGC,S", "EGC,D", "WSC,S", "WSC,D"];
        indCombinations = [ 0, 0; 0, 1; 1, 0; 1, 1];  %E/W; Shallow/Deep
        clf
        t = tiledlayout('flow');
        t.TileIndexing = 'columnmajor';
        clr = lines(1);
         mdls = {};
        for iInds = 1:height(indCombinations )
            for iDrv = 1:length(Drivers)
                nexttile
                ind = (tStPredictors.indDepth == indCombinations(iInds, 2) & tStPredictors.indEast == indCombinations(iInds, 1));
                x = tStPredictors{ind, Drivers{iDrv}};
                y = tStPredictors{ind, 'Richness'};
                mdl = plot_fit_CI(x, y, 60, clr, 0.75);
                mdls{end+1} = mdl;
                f_Lbls(Drivers_label{iDrv}, 'Richness');
                p = mdl.Coefficients.pValue(2);
                %slope and intercept
                in = mdl.Coefficients.Estimate(1);
                sl = mdl.Coefficients.Estimate(2);

                if p <0.05
                    title(sprintf('%s:  slope=%.2f, R^2=%1.g', LabelNames{iInds}, sl,  mdl.Rsquared.Ordinary))
                else
                    title(sprintf('%s: n.s., R^2=%1.g', LabelNames{iInds},  mdl.Rsquared.Ordinary))
                end
            end
            % nexttile
            % ind = (tStPredictors.indDepth == indCombinations(iInds, 2) & tStPredictors.indEast == indCombinations(iInds, 1));
            % x = tStPredictors{ind, Drivers{1}};
            % y = tStPredictors{ind, Drivers{2}};
            % mdl = plot_fit_CI(x, y, 60, clr, 0.5);
            % f_Lbls(Drivers_label{1}, Drivers_label{2});
            % p = mdl.Coefficients.pValue(2);
            % sl = mdl.Coefficients.Estimate(2);
            % if p <0.05
            %     title(sprintf('%s: %s~%.1f*%s, p=%1.e', LabelNames{iInds}, Drivers_eq{2}, sl, Drivers_eq{1}, p))
            % else
            %     title(LabelNames{iInds})
            % end
        end

        AddLetters2Plots('HShift', -0.08, 'VShift', -0.04, 'Location', 'NorthWest')


        %% plot chl and T as a function of the year

      
%%
        Drivers = {'temp', 'chlorophyll_a_0'};
        Drivers_eq = {'t°', 'Chl-a'};
        Drivers_label = {'Temperature', 'Chl-a, \mug/L'};
        Drivers_transpow = [1, 0.25];
        [fg2, iFgNrNew] = addFindFigure([PlotID 'chl-T_year'], iFgNrNew);
        fg2.Position(3:4) = [1000 680];
        tiledlayout("vertical")
        clf
        clrs = lines(4);
        mdls = {};
        for iDrv = 1:length(Drivers)
            splots = [];
            leg = {};
            nexttile
            for iInds = 1:height(indCombinations )
                ind = (tStPredictors.indDepth == indCombinations(iInds, 2) & tStPredictors.indEast == indCombinations(iInds, 1));
                x = tStPredictors.Year(ind) + (tStPredictors.Month_doy(ind)-1)/12 + (iInds-2)*0.2-0.1;
                y = tStPredictors{ind, Drivers{iDrv}};
                [mdl, s] = plot_fit_CI(x, y, 30, clrs(iInds, :), 0.5, clrs(iInds, :), 'o', Drivers_transpow(iDrv));
                %f_plotResidualsmy(mdl);
                splots(end+1) = s;
                f_Lbls('Year', Drivers_label{iDrv});
                p = mdl.Coefficients.pValue(2);
                sl = mdl.Coefficients.Estimate(2);
                mdls{end+1} = mdl;
                hold on
                if p <0.05
                    leg{end+1}=sprintf('%s: slope=%.2f, R^2=%1.g', LabelNames{iInds}, sl,  mdl.Rsquared.Ordinary);
                else
                    leg{end+1}=sprintf('%s', LabelNames{iInds});
                    %title(LabelNames{iInds})
                end
            end
            legend(splots, leg, 'Location', 'best');
            xlim([2009, 2022])
            ax = gca;
            ax.XTick = [2009:2022];
        end
        AddLetters2Plots('HShift', -0.08, 'VShift', -0.04, 'Location', 'NorthWest')
        %% find mean temperature in EGC and WSC in summer months
        indSelectedSamples = tStPredictors.MonthNum>=6 & tStPredictors.MonthNum<=7;
        WSCTemp = tStPredictors.temp(tStPredictors.indEast == 1&indSelectedSamples);
        Results.Temp.WSCMean = nanmean(WSCTemp );
        Results.Temp.WSCSE =  nanstd(WSCTemp )/sqrt(sum(~isnan(WSCTemp )));

        EGCTemp = tStPredictors.temp(tStPredictors.indEast == 0&indSelectedSamples);
        Results.Temp.EGCMean = nanmean(EGCTemp );
        Results.Temp.EGCSE =  nanstd(EGCTemp )/sqrt(sum(~isnan(EGCTemp )));

        %% plot chl vs T

        Drivers = {'temp', 'chlorophyll_a_0'};
        Drivers_eq = {'t°', 'Chl-a'};
        Drivers_label = {'Temperature', 'Chl-a, \mug/L'};

        [fg3, iFgNrNew] = addFindFigure([PlotID 'chl-T'], iFgNrNew);
        fg3.Position(3:4) = [1000 680];
        t = tiledlayout('flow');
        t.TileIndexing = 'columnmajor';
        leg = {};
        mdls = {};
        for iInds = 1:height(indCombinations )
            nexttile
            ind = (tStPredictors.indDepth == indCombinations(iInds, 2) & tStPredictors.indEast == indCombinations(iInds, 1));
            x = tStPredictors{ind, Drivers{1}};
            y = tStPredictors{ind, Drivers{2}};


            mdl = plot_fit_CI(x, y, 60, clr, 0.75, 'k', 'o', 0.25);
            mdls{end+1} = mdl;
            %f_plotResidualsmy(mdl)
            f_Lbls(Drivers_label{1}, Drivers_label{2});
            p = mdl.Coefficients.pValue(2);
            %slope and intercept
            in = mdl.Coefficients.Estimate(1);
            sl = mdl.Coefficients.Estimate(2);
            if p <0.05
                title(sprintf('%s:  slope=%.2f, R^2=%1.g', LabelNames{iInds}, sl,  mdl.Rsquared.Ordinary))
            else
                title(sprintf('%s: n.s., R^2=%1.g', LabelNames{iInds},  mdl.Rsquared.Ordinary))
            end

        end
        AddLetters2Plots('HShift', -0.08, 'VShift', -0.04, 'Location', 'NorthWest')
        %%


    case 'FindAndSaveSignSpeciesTrends'
        %% 'FindAndSaveSignSpeciesTrends'
        tStPredictors = Data.tStPredictors;
        tTraits = Data.tTraits;
        meanFamAbundSmpl = Data.meanFamAbundSmpl;

        %Fitting species trends selected West/East Shallow/Deep
        %combinations
        indSelectedSamples = tStPredictors.MonthNum>=6 & tStPredictors.MonthNum<=7;
        grpstats(tStPredictors(indSelectedSamples, {'indDepth', 'indEast'}), {'indDepth', 'indEast'})
        %We have around 40 west samples and around 167-217 east samples
        tStPredictorsAdd = array2table(NaN(height(tStPredictors), 10));
        tStPredictorsAdd.Properties.VariableNames = ["SlAll", "SlWSh", "SlWDp", "SlESh", "SlEDp", "pAll", "pWSh", "pWDp", "pESh", "pEDp"];


        tTraitsAdd = array2table(NaN(height(tTraits), 10));
        tTraitsAdd.Properties.VariableNames = ["SlAll", "pAll", "SlWSh", "pWSh", "SlWDp", "pWDp", "SlESh", "pESh", "SlEDp", "pEDp"];
        tTraitsFits = [tTraits, tTraitsAdd];
        pValueMax = 0.01;
        ColumnNames = ["WSh", "WDp", "ESh", "EDp"];
        LabelNames = ["EGC,S", "EGC,D", "WSC,S", "WSC,D"];
        indCombinations = [ 0, 0; 0, 1; 1, 0; 1, 1];  %E/W; Shallow/Deep
        for i = 1:width(meanFamAbundSmpl)
            %if species contribute at least 0.1% of the population
            if mean(meanFamAbundSmpl(indSelectedSamples,i ))>=0.003
                %fit all data in June July
                lm = fitlm(tStPredictors.Year(indSelectedSamples), meanFamAbundSmpl(indSelectedSamples,i ));
                if lm.Coefficients.pValue(2) <pValueMax
                    tTraitsFits{i, ['SlAll']} = lm.Coefficients.Estimate(2);
                    tTraitsFits{i, ['pAll']} = lm.Coefficients.pValue(2);
                end
                %fit groups in region (West/East) and depth (Deep/Shallow)
                for iInds = 1:height(indCombinations )
                    ind = tStPredictors.indDepth == indCombinations(iInds, 2) & tStPredictors.indEast == indCombinations(iInds, 1);
                    lm = fitlm(tStPredictors.Year(indSelectedSamples&ind), meanFamAbundSmpl(indSelectedSamples&ind,i ));
                    if lm.Coefficients.pValue(2) <pValueMax
                        tTraitsFits{i, ['Sl' ColumnNames{iInds}]} = lm.Coefficients.Estimate(2);
                        tTraitsFits{i, ['p' ColumnNames{iInds}]} = lm.Coefficients.pValue(2);
                    end
                end
            end
        end

        indSign = tTraitsFits.pAll<pValueMax |tTraitsFits.pWSh<pValueMax |tTraitsFits.pWDp<pValueMax |tTraitsFits.pESh<pValueMax |tTraitsFits.pEDp<pValueMax ;
        writetable(tTraitsFits(indSign, :), '..\data2publ\HGReview\SignifcantSlopesAll.csv');
        LineStyles  = {'-', '--'};
        LineStyle = @(p) LineStyles{(p>0.01) + 1};

        fg.Position(3:4) = [1124.8 298];
        clf
        Clrs = lines(5); %f_Clrs_fresh(7);
        mrkSize = 20;
        %%Plot and fit diversity for the entire dataset
        plotYears = linspace(min(tStPredictors.Year), max(tStPredictors.Year));
        leg = {};
        lms = {};
        %fit groups in region (West/East) and depth (Deep/Shallow)
        for iInds = 1:height(indCombinations )
            ind = indSelectedSamples&(tStPredictors.indDepth == indCombinations(iInds, 2) & tStPredictors.indEast == indCombinations(iInds, 1));
            divSimpson = f_DiversityMetrics(meanFamAbundSmpl(ind,:), [], 'SimpsonESN', [], 2);
            rndOffSet = (rand(sum(ind), 1)-0.5)*0.5*0.3 + ((iInds-2)*0.2-0.1)*0.6;
            s(iInds) = scatter(tStPredictors.Year(ind)+rndOffSet, divSimpson, mrkSize, Clrs(iInds, :), "filled");
            s(iInds).MarkerFaceAlpha = 0.7;
            lm = fitlm(tStPredictors.Year(ind), divSimpson.^0.25);
            lms{iInds} = lm;
            hold on
             if lm.Coefficients.pValue(2) >0.01
                 p(iInds) = plot(plotYears, lm.predict(plotYears').^4, 'Color', Clrs(iInds, :), 'LineWidth', 3, 'LineStyle', '--');
                 leg(iInds) = {[char(LabelNames(iInds)) ]};
             else
                p(iInds) = plot(plotYears, lm.predict(plotYears').^4, 'Color', Clrs(iInds, :), 'LineWidth', 3, 'LineStyle', '-');
                leg(iInds) = {[char(LabelNames(iInds))   ', R^2=' NS(lm.Rsquared.Ordinary, 1)]};
             end

        end

        divSimpson = f_DiversityMetrics(meanFamAbundSmpl(indSelectedSamples,:), [], 'SimpsonESN', [], 2);
        rndOffSet = (rand(sum(indSelectedSamples), 1)-0.5)*0.5;
        lm = fitlm(tStPredictors.Year(indSelectedSamples), divSimpson.^0.25);
        lms{end+1} = lm;

        hold on
        p(5) = plot(plotYears, lm.predict(plotYears').^4, 'Color', Clrs(end, :),'LineWidth', 3, 'LineStyle', LineStyle(lm.Coefficients.pValue(2)));
        leg(5) = {['All, R^2=' NS(lm.Rsquared.Ordinary, 1)]};
        legend(p, leg, 'Location','northeastoutside')
        xlabel('Years');
        ylabel('Eff. ASV number')

        return

        %%
        fg.Position(3:4) = [1124.8  492];
        clf
        tiledlayout(2, 1)
        nexttile
        Clrs = f_Clrs_fresh(7);
        mrkSize = 20;
        %%Plot and fit diversity for the entire dataset
        plotYears = linspace(min(tStPredictors.Year), max(tStPredictors.Year));
        leg = {};
        %divIndex = 'Richness';%'SimpsonESN'
        divIndex = 'SimpsonESN'
        %fit groups in region (West/East) and depth (Deep/Shallow)
        for iInds = 1:height(indCombinations )
            ind = indSelectedSamples&(tStPredictors.indDepth == indCombinations(iInds, 2) & tStPredictors.indEast == indCombinations(iInds, 1));
            divSimpson = f_DiversityMetrics(meanFamAbundSmpl(ind,:), [], divIndex, [], 2);
            rndOffSet = (rand(sum(ind), 1)-0.5)*0.5;
            s(iInds) = scatter(tStPredictors.Year(ind)+rndOffSet, divSimpson, mrkSize, Clrs(iInds, :), "filled");
            s(iInds).MarkerFaceAlpha = 0.5;
            lm = fitlm(tStPredictors.Year(ind), divSimpson);
            hold on
            if lm.Coefficients.pValue(2) >0.01
                p(iInds) = plot(plotYears, lm.predict(plotYears'), 'Color', Clrs(iInds, :), 'LineWidth', 3, 'LineStyle', '--');
                leg(iInds) = {[char(LabelNames(iInds)) ]};
            else
                p(iInds) = plot(plotYears, lm.predict(plotYears'), 'Color', Clrs(iInds, :), 'LineWidth', 3, 'LineStyle', '-');
                leg(iInds) = {[char(LabelNames(iInds)) ', slope=' NS(lm.Coefficients.Estimate(2), 2) char(177) NS(lm.Coefficients.SE(2), 1)]};
            end

        end

        divSimpson = f_DiversityMetrics(meanFamAbundSmpl(indSelectedSamples,:), [], divIndex, [], 2);
        rndOffSet = (rand(sum(indSelectedSamples), 1)-0.5)*0.5;
        lm = fitlm(tStPredictors.Year(indSelectedSamples), divSimpson);
        hold on
        p(5) = plot(plotYears, lm.predict(plotYears'), 'Color', Clrs(end, :),'LineWidth', 3, 'LineStyle', LineStyle(lm.Coefficients.pValue(2)));
        leg(5) = {['All, slope='  NS(lm.Coefficients.Estimate(2), 2) char(177) NS(lm.Coefficients.SE(2), 1)]};
        legend(p, leg, 'Location','northeastoutside')
        xlabel('Years');
        ylabel('Eff. ASV number')


        %%Plot and fit chl levels
        nexttile
        leg = {};
        %fit groups in region (West/East) and depth (Deep/Shallow)
        for iInds = 1:height(indCombinations )
            ind = indSelectedSamples&(tStPredictors.indDepth == indCombinations(iInds, 2) & tStPredictors.indEast == indCombinations(iInds, 1));
            chlLevel = tStPredictors.chlorophyll_a_0(ind);
            rndOffSet = (rand(sum(ind), 1)-0.5)*0.5;
            s(iInds) = scatter(tStPredictors.Year(ind)+rndOffSet, chlLevel, mrkSize, Clrs(iInds, :), "filled");
            s(iInds).MarkerFaceAlpha = 0.5;
            lm = fitlm(tStPredictors.Year(ind), chlLevel);
            hold on
            if lm.Coefficients.pValue(2) >0.01
                p(iInds) = plot(plotYears, lm.predict(plotYears'), 'Color', Clrs(iInds, :), 'LineWidth', 3, 'LineStyle', '--');
                leg(iInds) = {[char(LabelNames(iInds)) ]};
            else
                p(iInds) = plot(plotYears, lm.predict(plotYears'), 'Color', Clrs(iInds, :), 'LineWidth', 3, 'LineStyle', '-');
                leg(iInds) = {[char(LabelNames(iInds)) ', slope=' NS(lm.Coefficients.Estimate(2), 2) char(177) NS(lm.Coefficients.SE(2), 1)]};
            end

        end

        chlLevel = tStPredictors.chlorophyll_a_0(indSelectedSamples);
        rndOffSet = (rand(sum(indSelectedSamples), 1)-0.5)*0.5;
        lm = fitlm(tStPredictors.Year(indSelectedSamples), chlLevel);
        hold on
        p(5) = plot(plotYears, lm.predict(plotYears'), 'Color', Clrs(end, :),'LineWidth', 3, 'LineStyle', LineStyle(lm.Coefficients.pValue(2)));
        leg(5) = {['All, slope='  NS(lm.Coefficients.Estimate(2), 2) char(177) NS(lm.Coefficients.SE(2), 1)]};
        legend(p, leg, 'Location','northeastoutside')
        xlabel('Years');
        ylabel('Chl-a, µg/L')



    case 'plotSummerRichnessDistributions'
        %% plot annual trend in richness the most rich phylas in summer as a function of year
        % Load data and filter for summer months (June, July)
        tStPredictors = Data.tStPredictors;
        tSamples = Data.tSamples;
        idxSamplCols = Data.idxSamplCols;
        idxSpecNames = idxSamplCols(1)-1;
        topGroupName = Data.topGroupName;
        topGroupNameIndex = find(strcmp(tSamples.Properties.VariableNames, topGroupName));

        MainPhylas = ["Dinoflagellata", "Ochrophyta", "Haptophyta", "Ciliophora", "Sagenista", ...
            "Chlorophyta", "Cercozoa", "Radiolaria"];

        % Select summer months
        indSelectedSamples = tStPredictors.MonthNum >= 6 & tStPredictors.MonthNum <= 7;
        tStPredictors = tStPredictors(indSelectedSamples, :);
        tSamples = tSamples(:, [1:idxSpecNames, idxSamplCols]);
        idxSamplCols = idxSpecNames+1:width(tSamples);



        % Set groups which are not in this list to 'Others'
        indDiverseGroups = ismember(tSamples{:, topGroupName}, MainPhylas);
        tSamples{~indDiverseGroups, topGroupName} = "others";
        MainPhylas = [MainPhylas, "others"];
        nMostDiverseToKeep = length(MainPhylas);

        %make a long format: topGroupName, Year, Sample, Presence/Abs
        summerSamples = stack(tSamples, idxSamplCols, 'ConstantVariables', {topGroupName, 'Genus'}, 'NewDataVariableName', 'Abundance', 'IndexVariableName', 'Sample');
        summerSamples.Sample = string(summerSamples.Sample);
        % Join with environmental predictors
        tLongSamplesEvn = innerjoin(summerSamples, tStPredictors(:, {'Year', 'Sample', 'Lat', 'Lon', 'Month', 'indDay', 'indDepth', 'indEast'}), "Keys", "Sample");
        %
        % % Set presence/absence and filter for present samples
        tLongSamplesEvn.PresAbs = tLongSamplesEvn.Abundance > 1e-4;
        tLongSamplesEvn = tLongSamplesEvn(tLongSamplesEvn.PresAbs > 0, :);
        %

        %find richness of phyla per sample, group by sample
        tLongSamplesEvnPhylaRichn = grpstats(tLongSamplesEvn(:, {  'indEast','Year','Phylum','Sample', 'PresAbs'}), { 'indEast','Year','Phylum','Sample'}, 'sum');
        tLongSamplesEvnPhylaRichn.GroupCount = [];
        tLongSamplesEvnPhylaRichn = renamevars(tLongSamplesEvnPhylaRichn, "sum_PresAbs", "Richness");

        %find mean richness of phyla per year
        tLongSamplesEvnPhylaRichnYear = grpstats(tLongSamplesEvnPhylaRichn(:, {  'indEast','Year','Phylum','Richness'}), { 'indEast','Year','Phylum'}, {'mean', 'std'});
        tLongSamplesEvnPhylaRichnYear.GroupCount = [];

        % Define Column and Label Names for plotting
        LabelNames = ["EGC", "WSC"];
        indCombinations = [0, 1];  % E/W; Shallow/Deep
        ClrsPhyla = f_Clrs_fresh(nMostDiverseToKeep);  % Generate distinct colors for 8 phyla

        % loop through each region/depth combination
        clf
        tiledlayout(nMostDiverseToKeep, length(indCombinations(:)))
        for iInds = 1:length(indCombinations)
            ind = tLongSamplesEvnPhylaRichnYear.indEast == indCombinations(iInds);
            % Filter samples for the current region and depth
            tLongSamplesEvnGroup = tLongSamplesEvnPhylaRichnYear(ind, :);
            % Loop over each phylum and plot
            for iPhyla = 1:nMostDiverseToKeep
                nexttile((iPhyla-1)*2 + iInds)
                phylaName = MainPhylas{iPhyla};
                % Filter the data for the current phylum
                indPhylum = strcmp(tLongSamplesEvnGroup.Phylum, phylaName);
                phylumData = tLongSamplesEvnGroup(indPhylum, :);

                % Extract year and abundance for scatter plot and regression


                % Plot scatter and fit linear regression for each phylum
                lm = f_fitplotLinearRegression(phylumData.Year, phylumData.mean_Richness, ...
                    phylumData.std_Richness, ClrsPhyla(iPhyla, :));
                title(phylaName)
            end

            % Title and labels for each subplot
            title(char(LabelNames(iInds)));
            xlabel('Year');
            ylabel('Abundance');

            hold off;
        end

        % Set the main title for the entire figure
        %sgtitle('Linear Regression of 8 Most Diverse Phyla for Different Depths and Regions in Summer Months');


        AddLetters2Plots('HShift', 0.005, 'VShift', 0.01, 'Location', 'NorthWest')

    %% plot distribution of tax groups by months /depth/east west
    case 'plotRichnessDistributions'
        fg.Position(3:4) = [1.4576e+03 545];
        clf
        tiledlayout(1, 3, "TileSpacing","compact");
        tSamples = Data.tSamples;
        idxSamplCols = Data.idxSamplCols;
        tStPredictors = Data.tStPredictors;
        topGroupName = Data.topGroupName;

        %we have samples order genera x sample
        %we need to have order genera richness month
        %this we can do from long table with order genera sample month
        %so we stack the tSample to get order genera sample abuandance
        tLongSamples = stack(tSamples, idxSamplCols, 'ConstantVariables', {topGroupName, 'Genus'}, ...
            'NewDataVariableName',  'Abundance', 'IndexVariableName', 'Sample');
        tLongSamples.Properties.RowNames= {};  %remove row names
        tLongSamples.Sample = cellstr(tLongSamples.Sample);
        arr = cellstr(tLongSamples{:, topGroupName});
        tLongSamples(:, topGroupName) = [];
        tLongSamples(:, topGroupName) = arr;
        %join it with env factors by sample name (should not change the length of the table)
        tLongSamplesEvn = innerjoin(tLongSamples, ...
            tStPredictors(:, {'Year', 'Sample', 'Lat',  'Lon', 'Month', 'indDay', 'indDepth', 'indEast'}),...
            "Keys","Sample");
        clearvars tLongSamples;
        %set presence absence
        tLongSamplesEvn.Abundance = tLongSamplesEvn.Abundance>1e-4;
        tLongSamplesEvn = tLongSamplesEvn(tLongSamplesEvn.Abundance>0, :);
        %find most diverse Phylum (topGroupName) and set other orders to 'Others';
        nMostDiverseToKeep= 8;
        %group by topGroupName to find most diverse orders in each sample
        %find number of genera od each phylum in each sample
        tLongSamplesGroup = grpstats(tLongSamplesEvn(:, {topGroupName 'Abundance', 'Sample'}), ...
            {topGroupName, 'Sample'}, {'sum'});
        %find the max number of genera for each Phylum
        tLongSamplesGroup = grpstats(tLongSamplesGroup(:, {topGroupName 'sum_Abundance'}), ...
            {topGroupName}, {'mean'});

        tLongSamplesGroup = sortrows(tLongSamplesGroup, "mean_sum_Abundance", "descend");
        nMostDiverseToKeep = min(size(tLongSamplesGroup, 1), nMostDiverseToKeep);
        indDiverseGroups = ismember(tLongSamplesEvn{:, topGroupName}, tLongSamplesGroup{1:nMostDiverseToKeep, topGroupName});
        %set groups which are not in this list to Others
        tLongSamplesEvn.GroupTaxa = tLongSamplesEvn{:, topGroupName};
        tTaxaList = tLongSamplesGroup{1:nMostDiverseToKeep, topGroupName}';
        if sum(~indDiverseGroups)>0
            tLongSamplesEvn.GroupTaxa(~indDiverseGroups) = {'others'};
            tTaxaList{end+1}='others';
        end
        Results.tLongSamplesGroup = tLongSamplesGroup;

        %%define KeyFactors
        KeyFactors = {'MonthNum', 'indDepth', 'indEast'};
        LineWidth = 3;
        %% make a loop over keyfactors
        for iKF=1:length(KeyFactors)
            keyFactor = KeyFactors{iKF};
            %group by order, env_factor to get richness
            switch keyFactor
                case 'MonthNum'
                    %find average richness across samples

                    tLongSamplesEvnGroupSample = grpstats(tLongSamplesEvn(:, {'GroupTaxa',  'Sample', 'indDay', 'Abundance'}), ...
                        {'GroupTaxa', 'Sample',  'indDay'}, {'sum'});
                    tLongSamplesEvnGroup = grpstats(tLongSamplesEvnGroupSample(:, {'GroupTaxa',  'indDay',  'sum_Abundance'}), ...
                        {'GroupTaxa',  'indDay'}, {'mean', 'std', 'q05', 'q95'});

        

                    %I want to find number of genera in a sample in each Phylum
                    %group data by samples and find the count where
                    %abundance > 0;

                    nexttile;
                    %make links for the diagram
                    tLongSamplesEvnGroup = sortrows(tLongSamplesEvnGroup, {'GroupTaxa', 'indDay'});
                    gplotmy(tLongSamplesEvnGroup.indDay/30.417+1, tLongSamplesEvnGroup.mean_sum_Abundance, tLongSamplesEvnGroup.GroupTaxa, ...
                        tTaxaList, f_Clrs_fresh(length(tTaxaList), 'Order', 'my'), [3, 300],  'LineWidth', LineWidth);
                    hold on
                    tLongSamplesEvnGroupTotal = grpstats(tLongSamplesEvnGroup(:, {'indDay', 'mean_sum_Abundance'}), 'indDay', 'sum');
                    plot(tLongSamplesEvnGroupTotal.indDay/30.417+1, tLongSamplesEvnGroupTotal.sum_mean_sum_Abundance, ...
                        'o-', 'LineWidth', LineWidth, 'DisplayName', 'Total',  'Color', 0.75*[1, 1, 1]);
                    hold off;
                    ylabel('Richness');
                    xlabel('Month');

                case 'indDepth'
                    tLongSamplesEvnGroupSample = grpstats(tLongSamplesEvn(:, {'GroupTaxa',  'Sample', keyFactor, 'Abundance'}), ...
                        {'GroupTaxa', 'Sample', keyFactor}, {'sum'});
                    tLongSamplesEvnGroup = grpstats(tLongSamplesEvnGroupSample(:, {'GroupTaxa',  keyFactor, 'sum_Abundance'}), ...
                        {'GroupTaxa', keyFactor}, {'mean', 'std'});

                    % tLongSamplesEvnGroup = grpstats(tLongSamplesEvn(:, {'GroupTaxa',  keyFactor, 'Abundance'}), ...
                    %     {'GroupTaxa', keyFactor}, {'sum'});
                    FactorList = {'<30', '>=30'};
                    tLongSamplesEvnGroup.Depth = categorical(FactorList(tLongSamplesEvnGroup.indDepth+1)');
                    links= table2cell(tLongSamplesEvnGroup(:, {'GroupTaxa', 'Depth', 'mean_sum_Abundance'}));
                    nexttile;
                    gplotmy(tLongSamplesEvnGroup.Depth, tLongSamplesEvnGroup.mean_sum_Abundance, ...
                        tLongSamplesEvnGroup.GroupTaxa,  tTaxaList, f_Clrs_fresh(length(tTaxaList), 'Order', 'my'), [3, 300],'LineWidth', LineWidth);
                    hold on
                    tLongSamplesEvnGroupTotal = grpstats(tLongSamplesEvnGroup(:, {'Depth', 'mean_sum_Abundance'}), 'Depth', 'sum');
                    plot(tLongSamplesEvnGroupTotal.Depth, tLongSamplesEvnGroupTotal.sum_mean_sum_Abundance, ...
                        'o-', 'LineWidth', LineWidth, 'DisplayName', 'Total',  'Color', 0.75*[1, 1, 1]);
                    hold off;
                    xlabel('Depth');

                case 'indEast'
                    tLongSamplesEvnGroupSample = grpstats(tLongSamplesEvn(:, {'GroupTaxa',  'Sample', keyFactor, 'Abundance'}), ...
                        {'GroupTaxa', 'Sample', keyFactor}, {'sum'});
                    tLongSamplesEvnGroup = grpstats(tLongSamplesEvnGroupSample(:, {'GroupTaxa',  keyFactor, 'sum_Abundance'}), ...
                        {'GroupTaxa', keyFactor}, {'mean', 'std'});

                    %tLongSamplesEvnGroup = grpstats(tLongSamplesEvn(:, {'GroupTaxa',  keyFactor, 'Abundance'}), ...
                    %  {'GroupTaxa', keyFactor}, {'sum'});
                    FactorList = {'EGC', 'WSC'};
                    tLongSamplesEvnGroup.Locations = categorical(FactorList(tLongSamplesEvnGroup.indEast+1)');
                    links= table2cell(tLongSamplesEvnGroup(:, {'GroupTaxa', 'Locations', 'mean_sum_Abundance'}));
                    nexttile;
                    gplotmy(tLongSamplesEvnGroup.Locations, tLongSamplesEvnGroup.mean_sum_Abundance, ...
                        tLongSamplesEvnGroup.GroupTaxa,  tTaxaList, f_Clrs_fresh(length(tTaxaList), 'Order', 'my'), [3, 300],'LineWidth', LineWidth);
                    hold on
                    tLongSamplesEvnGroupTotal = grpstats(tLongSamplesEvnGroup(:, {'Locations', 'mean_sum_Abundance'}), 'Locations', 'sum');
                    plot(tLongSamplesEvnGroupTotal.Locations, tLongSamplesEvnGroupTotal.sum_mean_sum_Abundance, ...
                        'o-', 'LineWidth', LineWidth, 'DisplayName', 'Total',  'Color', 0.75*[1, 1, 1]);
                    hold off;
                    xlabel('Location');
                    legend('show', 'Location', 'northeastoutside');


            end


        end
        AddLetters2Plots('HShift', -0.02, 'VShift', -0.07, 'Location', 'SouthEast')

     case 'plotRichnessDistributionsError'
     %% new plot distribution of tax groups by months /depth/east west with error 
        fg.Position(3:4) = [1.4576e+03 545];
        clf
        tiledlayout(1, 3, "TileSpacing","compact");
        tSamples = Data.tSamples;
        idxSamplCols = Data.idxSamplCols;
        tStPredictors = Data.tStPredictors;
        topGroupName = Data.topGroupName;

        %we have samples order genera x sample
        %we need to have order genera richness month
        %this we can do from long table with order genera sample month
        %so we stack the tSample to get order genera sample abuandance
        tLongSamples = stack(tSamples, idxSamplCols, 'ConstantVariables', {topGroupName, 'Genus'}, ...
            'NewDataVariableName',  'Abundance', 'IndexVariableName', 'Sample');
        tLongSamples.Properties.RowNames= {};  %remove row names
        tLongSamples.Sample = cellstr(tLongSamples.Sample);
        arr = cellstr(tLongSamples{:, topGroupName});
        tLongSamples(:, topGroupName) = [];
        tLongSamples(:, topGroupName) = arr;
        %join it with env factors by sample name (should not change the length of the table)
        tLongSamplesEvn = innerjoin(tLongSamples, ...
            tStPredictors(:, {'Year', 'Sample', 'Lat',  'Lon', 'Month', 'indDay', 'indDepth', 'indEast'}),...
            "Keys","Sample");
        clearvars tLongSamples;
        %set presence absence
        tLongSamplesEvn.FloatAbundance = tLongSamplesEvn.Abundance;
        tLongSamplesEvn.Abundance = double(tLongSamplesEvn.Abundance>1e-4);
        tLongSamplesEvn = tLongSamplesEvn(tLongSamplesEvn.Abundance>0, :);
        
        %find most diverse Phylum (topGroupName) and set other orders to 'Others';
        nMostDiverseToKeep= 8;
        %group by topGroupName to find most diverse orders in each sample
        %find number of genera od each phylum in each sample
        tLongSamplesGroup = grpstats(tLongSamplesEvn(:, {topGroupName 'Abundance', 'Sample'}), ...
            {topGroupName, 'Sample'}, {'sum'});
        %find the max number of genera for each Phylum
        tLongSamplesGroup = grpstats(tLongSamplesGroup(:, {topGroupName 'sum_Abundance'}), ...
            {topGroupName}, {'mean'});

        tLongSamplesGroup = sortrows(tLongSamplesGroup, "mean_sum_Abundance", "descend");
        nMostDiverseToKeep = min(size(tLongSamplesGroup, 1), nMostDiverseToKeep);
        indDiverseGroups = ismember(tLongSamplesEvn{:, topGroupName}, tLongSamplesGroup{1:nMostDiverseToKeep, topGroupName});
        %set groups which are not in this list to Others
        tLongSamplesEvn.GroupTaxa = tLongSamplesEvn{:, topGroupName};
        tTaxaList = tLongSamplesGroup{1:nMostDiverseToKeep, topGroupName}';
        if sum(~indDiverseGroups)>0
            tLongSamplesEvn.GroupTaxa(~indDiverseGroups) = {'others'};
            tTaxaList{end+1}='others';
        end
        Results.tLongSamplesGroup = tLongSamplesGroup;

        %%define KeyFactors
        KeyFactors = {'MonthNum', 'indDepth', 'indEast'};
        LineWidth = 3;
        %functions to define quantiles 
        q05 = @(x) quantile(x, 0.25);
        q95 = @(x) quantile(x, 0.75);


        %% make a loop over keyfactors

        for iKF=1:length(KeyFactors)
            keyFactor = KeyFactors{iKF};
            %group by order, env_factor to get richness
            switch keyFactor
                case 'MonthNum'
                    %find average richness across samples

                    tLongSamplesEvnGroupSample = grpstats(tLongSamplesEvn(:, {'GroupTaxa',  'Sample', 'indDay', 'Abundance'}), ...
                        {'GroupTaxa', 'Sample',  'indDay'}, {'sum'});
                    tLongSamplesEvnGroup = grpstats(tLongSamplesEvnGroupSample(:, {'GroupTaxa',  'indDay',  'sum_Abundance'}), ...
                        {'GroupTaxa',  'indDay'}, {@median, q05, q95});
                    tLongSamplesEvnGroup = renamevars(tLongSamplesEvnGroup, ["median_sum_Abundance", "Fun2_sum_Abundance", "Fun3_sum_Abundance"], ...
                        ["Richness", "q05", "q95"]);
             
                    %I want to find number of genera in a sample in each Phylum
                    %group data by samples and find the count where
                    %abundance > 0;

                    nexttile;
                    cla
                    %make links for the diagram
                    tLongSamplesEvnGroup = sortrows(tLongSamplesEvnGroup, {'GroupTaxa', 'indDay'});
                    gplotmy_error(tLongSamplesEvnGroup.indDay/30.417+1, tLongSamplesEvnGroup.Richness, tLongSamplesEvnGroup.q05, tLongSamplesEvnGroup.q95, tLongSamplesEvnGroup.GroupTaxa, ...
                        tTaxaList, f_Clrs_fresh(length(tTaxaList), 'Order', 'my'), [1, 100],  'LineWidth', LineWidth);
    %                hold on
                   %  tLongSamplesEvnGroupTotal = grpstats(tLongSamplesEvnGroup(:, {'indDay', 'Richness'}), 'indDay', 'sum');
                   % plot(tLongSamplesEvnGroupTotal.indDay/30.417+1, tLongSamplesEvnGroupTotal.sum_Richness, ...
                   %      'o-', 'LineWidth', LineWidth, 'DisplayName', 'Total',  'Color', 0.75*[1, 1, 1]);
                   %  hold off;
                    ylabel('Richness');
                    xlabel('Month');

                case 'indDepth'
                    tLongSamplesEvnGroupSample = grpstats(tLongSamplesEvn(:, {'GroupTaxa',  'Sample', keyFactor, 'Abundance'}), ...
                        {'GroupTaxa', 'Sample', keyFactor}, {'sum'});
                    tLongSamplesEvnGroup = grpstats(tLongSamplesEvnGroupSample(:, {'GroupTaxa',  keyFactor, 'sum_Abundance'}), ...
                        {'GroupTaxa', keyFactor}, {@median, q05, q95});
                    tLongSamplesEvnGroup = renamevars(tLongSamplesEvnGroup, ["median_sum_Abundance", "Fun2_sum_Abundance", "Fun3_sum_Abundance"], ...
                        ["Richness", "q05", "q95"]);

                    % tLongSamplesEvnGroup = grpstats(tLongSamplesEvn(:, {'GroupTaxa',  keyFactor, 'Abundance'}), ...
                    %     {'GroupTaxa', keyFactor}, {'sum'});
                    FactorList = {'<30', '>=30'};
                    tLongSamplesEvnGroup.Depth = categorical(FactorList(tLongSamplesEvnGroup.indDepth+1)');
                    links= table2cell(tLongSamplesEvnGroup(:, {'GroupTaxa', 'Depth', 'Richness'}));
                    nexttile;
                    % gplotmy(tLongSamplesEvnGroup.Depth, tLongSamplesEvnGroup.Richness, ...
                    %     tLongSamplesEvnGroup.GroupTaxa,  tTaxaList, f_Clrs_fresh(length(tTaxaList), 'Order', 'my'), [3, 300],'LineWidth', LineWidth);
                     gplotmy_error(tLongSamplesEvnGroup.Depth, tLongSamplesEvnGroup.Richness, tLongSamplesEvnGroup.q05, tLongSamplesEvnGroup.q95, tLongSamplesEvnGroup.GroupTaxa, ...
                        tTaxaList, f_Clrs_fresh(length(tTaxaList), 'Order', 'my'), [1, 100],  'LineWidth', LineWidth);
                   % hold on
                   %  tLongSamplesEvnGroupTotal = grpstats(tLongSamplesEvnGroup(:, {'Depth', 'Richness'}), 'Depth', 'sum');
                   %  plot(tLongSamplesEvnGroupTotal.Depth, tLongSamplesEvnGroupTotal.sum_Richness, ...
                   %      'o-', 'LineWidth', LineWidth, 'DisplayName', 'Total',  'Color', 0.75*[1, 1, 1]);
                   %  hold off;
                   %  xlabel('Depth');

                case 'indEast'
                    %Find unique genera for each GroupTaxa (phylum) in east
                    %and west region
                    tLongSamplesEvnPhylaSpec = grpstats(tLongSamplesEvn(:, {'GroupTaxa', 'Genus',  keyFactor, 'Abundance', 'FloatAbundance'}), ...
                        {'GroupTaxa', 'Genus',  keyFactor}, {'mean'});
                    %Find jaccard index of phylum similarity between the
                    %regions
                    Results.simTable = hg_sd_Richness_f_TaxaSimilarity(tLongSamplesEvnPhylaSpec);

                    tLongSamplesEvnGroupSample = grpstats(tLongSamplesEvn(:, {'GroupTaxa',  'Sample', keyFactor, 'Abundance'}), ...
                        {'GroupTaxa', 'Sample', keyFactor}, {'sum'});
                    tLongSamplesEvnGroup = grpstats(tLongSamplesEvnGroupSample(:, {'GroupTaxa',  keyFactor, 'sum_Abundance'}), ...
                        {'GroupTaxa', keyFactor}, {@median, q05, q95});
                    tLongSamplesEvnGroup = renamevars(tLongSamplesEvnGroup, ["median_sum_Abundance", "Fun2_sum_Abundance", "Fun3_sum_Abundance"], ...
                        ["Richness", "q05", "q95"]);

                    %tLongSamplesEvnGroup = grpstats(tLongSamplesEvn(:, {'GroupTaxa',  keyFactor, 'Abundance'}), ...
                    %  {'GroupTaxa', keyFactor}, {'sum'});
                    FactorList = {'EGC', 'WSC'};
                    tLongSamplesEvnGroup.Locations = categorical(FactorList(tLongSamplesEvnGroup.indEast+1)');
                    links= table2cell(tLongSamplesEvnGroup(:, {'GroupTaxa', 'Locations', 'Richness'}));
                    nexttile;
                    gplotmy_error(tLongSamplesEvnGroup.Locations, tLongSamplesEvnGroup.Richness, tLongSamplesEvnGroup.q05, tLongSamplesEvnGroup.q95, tLongSamplesEvnGroup.GroupTaxa, ...
                        tTaxaList, f_Clrs_fresh(length(tTaxaList), 'Order', 'my'), [1, 100],  'LineWidth', LineWidth);

                    % gplotmy(tLongSamplesEvnGroup.Locations, tLongSamplesEvnGroup.Richness, ...
                    %     tLongSamplesEvnGroup.GroupTaxa,  tTaxaList, f_Clrs_fresh(length(tTaxaList), 'Order', 'my'), [3, 300],'LineWidth', LineWidth);
                    % hold on
                    % tLongSamplesEvnGroupTotal = grpstats(tLongSamplesEvnGroup(:, {'Locations', 'Richness'}), 'Locations', 'sum');
                    % plot(tLongSamplesEvnGroupTotal.Locations, tLongSamplesEvnGroupTotal.sum_Richness, ...
                    %     'o-', 'LineWidth', LineWidth, 'DisplayName', 'Total',  'Color', 0.75*[1, 1, 1]);
                    % hold off;
                    xlabel('Location');
                    legend('show', 'Location', 'northeastoutside');


            end


        end
        AddLetters2Plots('HShift', -0.02, 'VShift', -0.07, 'Location', 'SouthEast')



    case 'plotRichnessDistributionsErrorOverYear'
     %% new plot distribution of tax groups richness by yeara
        fg.Position(3:4) = [1.4576e+03 545];
        clf
        tSamples = Data.tSamples;
        idxSamplCols = Data.idxSamplCols;
        FirstSampleColumn = idxSamplCols(1);
        tStPredictors = Data.tStPredictors;
        topGroupName = Data.topGroupName;


        %Filter summer data
        indSelectedSamples = tStPredictors.MonthNum>=6 & tStPredictors.MonthNum<=7;
        tStPredictors = tStPredictors(indSelectedSamples, :);
        idxSamplCols = idxSamplCols(indSelectedSamples);
        tSamples = [tSamples(:, 1:FirstSampleColumn-1) tSamples(:, idxSamplCols)];
        idxSamplCols = FirstSampleColumn:width(tSamples);


        %we have samples order genera x sample
        %we need to have order genera richness year
        %this we can do from long table with order genera sample year
        %so we stack the tSample to get order genera sample abuandance
        tLongSamples = stack(tSamples, idxSamplCols, 'ConstantVariables', {topGroupName, 'Genus'}, ...
            'NewDataVariableName',  'Abundance', 'IndexVariableName', 'Sample');
        tLongSamples.Properties.RowNames= {};  %remove row names
        tLongSamples.Sample = cellstr(tLongSamples.Sample);
        arr = cellstr(tLongSamples{:, topGroupName});
        tLongSamples(:, topGroupName) = [];
        tLongSamples(:, topGroupName) = arr;
        %join it with env factors by sample name (should not change the length of the table)
        tLongSamplesEvn = innerjoin(tLongSamples, ...
            tStPredictors(:, {'Year', 'Sample', 'Lat',  'Lon', 'Month', 'indDay', 'indDepth', 'indEast'}),...
            "Keys","Sample");
        clearvars tLongSamples;
        %set presence absence
        tLongSamplesEvn.FloatAbundance = tLongSamplesEvn.Abundance;
        tLongSamplesEvn.Abundance = double(tLongSamplesEvn.Abundance>1e-4);
        tLongSamplesEvn = tLongSamplesEvn(tLongSamplesEvn.Abundance>0, :);
        
        %find most diverse Phylum (topGroupName) and set other orders to 'Others';
        nMostDiverseToKeep= 8;
        %group by topGroupName to find most diverse orders in each sample
        %find number of genera od each phylum in each sample
        tLongSamplesGroup = grpstats(tLongSamplesEvn(:, {topGroupName 'Abundance', 'Sample'}), ...
            {topGroupName, 'Sample'}, {'sum'});
        %find the max number of genera for each Phylum
        tLongSamplesGroup = grpstats(tLongSamplesGroup(:, {topGroupName 'sum_Abundance'}), ...
            {topGroupName}, {'mean'});

        tLongSamplesGroup = sortrows(tLongSamplesGroup, "mean_sum_Abundance", "descend");
        nMostDiverseToKeep = min(size(tLongSamplesGroup, 1), nMostDiverseToKeep);
        indDiverseGroups = ismember(tLongSamplesEvn{:, topGroupName}, tLongSamplesGroup{1:nMostDiverseToKeep, topGroupName});
        %set groups which are not in this list to Others
        tLongSamplesEvn.GroupTaxa = tLongSamplesEvn{:, topGroupName};
        tTaxaList = tLongSamplesGroup{1:nMostDiverseToKeep, topGroupName}';
        if sum(~indDiverseGroups)>0
            tLongSamplesEvn.GroupTaxa(~indDiverseGroups) = {'others'};
            tTaxaList{end+1}='others';
        end
        Results.tLongSamplesGroup = tLongSamplesGroup;

        %%define KeyFactors
        KeyFactors = {'Year'};
        LineWidth = 3;
        %functions to define quantile
        q05 = @(x) quantile(x, 0.25);
        q95 = @(x) quantile(x, 0.75);


        %%make a loop over keyfactors

        for iKF=1:length(KeyFactors)
            keyFactor = KeyFactors{iKF};
            %group by order, env_factor to get richness
            switch keyFactor
                case 'Year'
                    %find average richness across samples

                    tLongSamplesEvnGroupSample = grpstats(tLongSamplesEvn(:, {'GroupTaxa',  'Sample', 'Year', 'Abundance'}), ...
                        {'GroupTaxa', 'Sample',  'Year'}, {'sum'});
                    tLongSamplesEvnGroup = grpstats(tLongSamplesEvnGroupSample(:, {'GroupTaxa',  'Year',  'sum_Abundance'}), ...
                        {'GroupTaxa',  'Year'}, {@median, q05, q95});
                    tLongSamplesEvnGroup = renamevars(tLongSamplesEvnGroup, ["median_sum_Abundance", "Fun2_sum_Abundance", "Fun3_sum_Abundance"], ...
                        ["Richness", "q05", "q95"]);
             
                    %I want to find number of genera in a sample in each Phylum
                    %group data by samples and find the count where
                    %abundance > 0;

                    nexttile;
                    cla
                    %make links for the diagram
                    tLongSamplesEvnGroup = sortrows(tLongSamplesEvnGroup, {'GroupTaxa', 'Year'});
                    gplotmy_error(tLongSamplesEvnGroup.Year, tLongSamplesEvnGroup.Richness, tLongSamplesEvnGroup.q05, tLongSamplesEvnGroup.q95, tLongSamplesEvnGroup.GroupTaxa, ...
                        tTaxaList, f_Clrs_fresh(length(tTaxaList), 'Order', 'my'), [1, 100],  'LineWidth', LineWidth);
    %                hold on
                   %  tLongSamplesEvnGroupTotal = grpstats(tLongSamplesEvnGroup(:, {'indDay', 'Richness'}), 'indDay', 'sum');
                   % plot(tLongSamplesEvnGroupTotal.indDay/30.417+1, tLongSamplesEvnGroupTotal.sum_Richness, ...
                   %      'o-', 'LineWidth', LineWidth, 'DisplayName', 'Total',  'Color', 0.75*[1, 1, 1]);
                   %  hold off;
                    ylabel('Richness');
                    xlabel('Year');

             
                    legend('show', 'Location', 'northeastoutside');


            end


        end
      
        

    case 'plotRichnessMaps'
        %% Make richness maps for west and east
        tSamples = Data.tSamples;
        idxSamplCols = Data.idxSamplCols;
        tStPredictors = Data.tStPredictors;
        fg.Position(3:4) = [1000 680];
        clf
        [fg2, iFgNrNew] = addFindFigure([PlotID 'chl-R'], iFgNrNew);
        fg2.Position(3:4) = [1000 680];

        [fg3, iFgNrNew] = addFindFigure([PlotID 'Rich-resid'], iFgNrNew);
        fg3.Position(3:4) = [1000 680];
        
        %Merge it with environmental data
        divSimpson = f_DiversityMetrics(tSamples{:, idxSamplCols}, [], 'SimpsonESN', [], 1);
        tStPredictors.sampleRichness = divSimpson';
        %divSimpson = f_DiversityMetrics(tSamples{:, idxSamplCols}, [], 'Richness', [], 1);
        tStPredictors.sampleRichness2 = sum(tSamples{:, idxSamplCols}>0, 1)';
       % tStPredictors.sampleRichness  = tStPredictors.sampleRichness2;
        %Plot richness as a function of month and depth for west and east
        titles = {'EGC', 'WSC'};
        modelsDiv = {};
        modelsChl = {};
        modelsDivChl = {};
        modelSpecification = {'sampleRichness~1+Depth', 'interactions'};
        modelSpecificationChl = {'chlorophyll_a_0~1+Depth', 'interactions'};
        clrs = f_Clrs_fresh(2);
        %%
        for iWE = 0:1
            %plot chl and richness distribution
            ind = tStPredictors.indEast == iWE;
            IndIncludeChl = tStPredictors.chlorophyll_a_0 < 3;
          %  ind  = ind & IndIncludeChl;
            
            tStPredictors.sampleRichness_tranf = tStPredictors.sampleRichness.^0.25;
            mod = stepwiselm(tStPredictors(ind, ["Month_doy", "Depth", "sampleRichness_tranf"]), ...
                'constant', 'upper', 'quadratic', 'ResponseVar','sampleRichness_tranf', ...
                'Criterion','bic', Verbose=2); 
            figure(117)
            f_plotResidualsmy(mod);
            disp(mod)
            
            %mod = fitlm(tStPredictors(ind, ["Month_doy", "Depth", "sampleRichness"]), modelSpecification{iWE+1}, 'ResponseVar','sampleRichness');
            modelsDiv{end+1} = mod;

            figure(fg)
            mrk_size = 40;
            face_alpha = 0.75;
            t = nexttile(iWE+1);
            s = scatter3(tStPredictors.Month_doy(ind), tStPredictors.Depth(ind), tStPredictors.sampleRichness(ind), mrk_size, tStPredictors.sampleRichness(ind), 'filled');
            s.MarkerFaceAlpha = face_alpha;
            xGrid = linspace(min(tStPredictors.Month_doy(ind)), max(tStPredictors.Month_doy(ind)), 20);
            yGrid = linspace(0, 100, 25);
            [XGrid, YGrid] = meshgrid(xGrid, yGrid);
            predictedRichness = mod.predict([XGrid(:), YGrid(:)]).^4;
            predictedRichness = reshape(predictedRichness, size(XGrid));
            hold on
            s = surf(xGrid, yGrid, predictedRichness, 'FaceAlpha',0.5,'EdgeColor','none');
            colormap(t , linspecer(20));
            cb = colorbar;
            xlabel('Month')
            ylabel('Depth')
            ylabel(cb, 'Eff. ASV number');
            title([titles{iWE+1}, ', R^2=' NS(mod.Rsquared.Ordinary, 2)]);
            ylim([0, 100]);
            t.YDir = "reverse";
            xlim([5.5, 10.5])
            view(0, 90)

            
            tStPredictors.chlorophyll_a_0_transf = (tStPredictors.chlorophyll_a_0).^(1/4);
            % modChl  = stepwiselm(tStPredictors(ind, ["Month_doy", "Depth", "chlorophyll_a_0_transf"]),...
            %     'constant', 'upper', 'interactions', 'ResponseVar','chlorophyll_a_0_transf', 'Criterion','bic', Verbose=2)
            %
            modChl = stepwiselm(tStPredictors(ind, ["Month_doy", "Depth", "chlorophyll_a_0_transf"]), ...
                'constant', 'upper', 'quadratic', 'ResponseVar','chlorophyll_a_0_transf',  'Criterion','bic', Verbose=2)
            figure(117)
            f_plotResidualsmy(modChl);
          

             %fitlm(tStPredictors(ind, ["Month_doy", "Depth", "chlorophyll_a_0"]), modelSpecificationChl{iWE+1}, 'ResponseVar','chlorophyll_a_0');
            modelsChl{end+1} = modChl;

           %Plot chl levels
            figure(fg)
            t = nexttile(iWE+3);
            s = scatter3(tStPredictors.Month_doy(ind), tStPredictors.Depth(ind), tStPredictors.chlorophyll_a_0(ind), mrk_size, tStPredictors.chlorophyll_a_0(ind), 'filled');
            s.MarkerFaceAlpha = face_alpha;
 
            predictedChl = modChl.predict([XGrid(:), YGrid(:)]).^4;
            predictedChl = reshape(predictedChl, size(XGrid));
            hold on
            s = surf(xGrid, yGrid, predictedChl, 'FaceAlpha',0.5,'EdgeColor','none');
            colormap(t , linspecer(20));
            cb = colorbar;
            xlabel('Month')
            ylabel('Depth')
            ylabel(cb, 'Chl-a');
            title([titles{iWE+1}, ', R^2=' NS(modChl.Rsquared.Ordinary, 2) ]);
            ylim([0, 100]);
            t.YDir = "reverse";
            xlim([5.5, 10.5])
            view(0, 90)

            %plot richness vs chl
            t2Fit = table(tStPredictors.chlorophyll_a_0(ind).^.25, tStPredictors.sampleRichness(ind).^.25, tStPredictors.sampleRichness2(ind));
            t2Fit.Properties.VariableNames = {'Chl025', 'ESN025', 'Richness'};
            mod_lin = fitlm(t2Fit(:, {'Chl025', 'ESN025'}));
            modelsDivChl{end+1} = mod_lin;
            %mod_lin = fitlm(log10(tStPredictors.chlorophyll_a_0(ind)), log10(tStPredictors.sampleRichness(ind)));
            figure(117)
            f_plotResidualsmy(mod_lin);

            figure(fg2);
            nexttile(iWE+1)
            cla
            s = scatter(tStPredictors.chlorophyll_a_0(ind),  tStPredictors.sampleRichness(ind), mrk_size, clrs(iWE+1, :), 'filled');
            s.MarkerFaceAlpha = face_alpha;

            xGrid = linspace(min(tStPredictors.chlorophyll_a_0(ind)), max(tStPredictors.chlorophyll_a_0(ind)), 200);
            predictedRichness = mod_lin.predict(xGrid(:).^0.25).^4;
            hold on
            s = plot(xGrid', predictedRichness, 'Color', 'k', 'LineWidth',3);
            xlabel('Chl-a')
            ylabel('Eff. ASV number');
            %ylim([0, 35])
            [cor, p] = corr(tStPredictors.chlorophyll_a_0(ind),  tStPredictors.sampleRichness(ind), "Rows", "pairwise");
            title([titles{iWE+1}]);
            legend({ ['Data, r=' NS(cor, 2)], ['Model R^2=' NS(mod_lin.Rsquared.Adjusted, 2)]});


            mod_lin_rich = fitlm(t2Fit(:, {'Chl025', 'Richness'}));
            modelsDivChl{end+1} = mod_lin_rich;
            figure(117)
            f_plotResidualsmy(mod_lin_rich);

            figure(fg2);
            nexttile(iWE+3)
            cla
            s = scatter(tStPredictors.chlorophyll_a_0(ind),  tStPredictors.sampleRichness2(ind), mrk_size, clrs(iWE+1, :), 'filled');
            s.MarkerFaceAlpha = face_alpha;
            xGrid = linspace(min(tStPredictors.chlorophyll_a_0(ind)), max(tStPredictors.chlorophyll_a_0(ind)), 200);
            predictedRichness = mod_lin_rich.predict(xGrid(:).^0.25);
            hold on
            s = plot(xGrid', predictedRichness, 'Color', 'k', 'LineWidth',3);
            xlabel('Chl-a')
            ylabel('Species richness');
            %ylim([0, 35])
            [cor, p] = corr(tStPredictors.chlorophyll_a_0(ind),  tStPredictors.sampleRichness2(ind), "Rows", "pairwise");
            title([titles{iWE+1}]);
            legend({ ['Data, r=' NS(cor, 2)], ['Model R^2=' NS(mod_lin_rich.Rsquared.Adjusted, 2)]});

            %%%%%%%%%%%
            %plot richness vs temperature
            t2Fit = table(tStPredictors.temp(ind), tStPredictors.sampleRichness(ind).^.25, tStPredictors.sampleRichness2(ind));
            t2Fit.Properties.VariableNames = {'temp', 'ESN025', 'Richness'};
            mod_lin = fitlm(t2Fit(:, {'temp', 'ESN025'}));
            modelsDivChl{end+1} = mod_lin;
            %mod_lin = fitlm(log10(tStPredictors.chlorophyll_a_0(ind)), log10(tStPredictors.sampleRichness(ind)));
            figure(117)
            f_plotResidualsmy(mod_lin);

            figure(fg3);
            nexttile(iWE+1)
            cla
            s = scatter(tStPredictors.temp(ind),  tStPredictors.sampleRichness(ind), mrk_size, clrs(iWE+1, :), 'filled');
            s.MarkerFaceAlpha = face_alpha;

            xGrid = linspace(min(tStPredictors.temp(ind)), max(tStPredictors.temp(ind)), 200);
            predictedRichness = mod_lin.predict(xGrid(:)).^4;
            hold on
            s = plot(xGrid', predictedRichness, 'Color', 'k', 'LineWidth',3);
            xlabel('Temperature')
            ylabel('Eff. ASV number');
            %ylim([0, 35])
            [cor, p] = corr(tStPredictors.temp(ind),  tStPredictors.sampleRichness(ind), "Rows", "pairwise");
            title([titles{iWE+1}]);
            legend({ ['Data, r=' NS(cor, 2)], ['Model R^2=' NS(mod_lin.Rsquared.Adjusted, 2)]});


            mod_lin_rich = fitlm(t2Fit(:, {'temp', 'Richness'}));
            modelsDivChl{end+1} = mod_lin_rich;
            figure(117)
            f_plotResidualsmy(mod_lin_rich);

            figure(fg3);
            nexttile(iWE+3)
            cla
            s = scatter(tStPredictors.temp(ind),  tStPredictors.sampleRichness2(ind), mrk_size, clrs(iWE+1, :), 'filled');
            s.MarkerFaceAlpha = face_alpha;
            xGrid = linspace(min(tStPredictors.temp(ind)), max(tStPredictors.temp(ind)), 200);
            predictedRichness = mod_lin_rich.predict(xGrid(:));
            hold on
            s = plot(xGrid', predictedRichness, 'Color', 'k', 'LineWidth',3);
            xlabel('Temperature')
            ylabel('Species richness');
            %ylim([0, 35])
            [cor, p] = corr(tStPredictors.temp(ind),  tStPredictors.sampleRichness2(ind), "Rows", "pairwise");
            title([titles{iWE+1}]);
            legend({ ['Data, r=' NS(cor, 2)], ['Model R^2=' NS(mod_lin_rich.Rsquared.Adjusted, 2)]});




            
            
        end
        figure(fg);
        AddLetters2Plots
        figure(fg2);
        AddLetters2Plots
        figure(fg3);
        AddLetters2Plots
end