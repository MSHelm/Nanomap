function PlotDisorderMap
close all
addpath(genpath('Z:\user\mhelm1\Programming\MatLab\Utilities\export_fig'));
addpath(genpath('Z:\user\mhelm1\Programming\MatLab\Colormaps'));
%change colormap here
set(0, 'DefaultFigureColormap', viridis()) 

% cd 'Z:\user\mhelm1\Nanomap_Analysis\Analysis\ProteinDisorderMap'
cd 'Z:\user\mhelm1\Nanomap_Analysis\Analysis\ProteinDisorderMap\Presynapse'

%specify files to be loaded
% filenames = {'Mushroom_scores.mat', 'Mushroom_scores_normalized_copynum.mat', 'Flat_scores.mat', 'Flat_scores_normalized_copynum.mat'};
filenames = {'presynapse_scores.mat', 'presynapse_scores_normalized_copynum.mat'};

for filename = 1:numel(filenames)
    data = load(filenames{filename});

    %get rid of parameter maps we do not use for the respective file
    if contains(filenames{filename}, 'normalized_copynum')
        data = rmfield(data,{'Length', 'Mass', 'DisorderShort', 'IsoelectricPointAverage', 'IsoelectricPointAverageDifferenceToNeutral', 'Coil', 'StructuredRatio', 'Zagg', 'ZaggSC'});
    else
        data = rmfield(data,{'Mass', 'DisorderShort', 'IsoelectricPointAverage', 'IsoelectricPointAverageDifferenceToNeutral', 'Coil', 'ExtendedBetaSheet', 'AlphaHelix', 'StructuredRatio', 'Zagg', 'CopyMap'});
    end

    %get the fieldnames of the data and loop over the parameters, creating a
    %plot for each
    fields = fieldnames(data);
    for field = 1 : numel(fields)
        [x, y, z, values] = matrix_to_xyzv(data.(fields{field}));
        [x, y, z, values] = mask_data(x, y, z, values);
    
%         apply sqrt scaling to make the plots a bit better visible.
        cmap_values = sqrt(values);
        fig = figure;
        h = scatter3(x, y, z, 420, cmap_values, 'o', 'filled'); 
        alpha(0.25);
        
%         Add colorbar and rescale it to the true labels (since we use sqrt
%         scaling I apply quadratic function)
        cax = colorbar;
        cax_ticks = cax.TickLabels;
        cax_ticks = cellfun(@str2num, cax_ticks, 'UniformOutput', 0);
        cax_ticks = cellfun(@(x) power(x,2), cax_ticks);
        set(cax, 'TickLabels', cax_ticks);
        
        axis equal
        axis off
        title(fields{field});
        
        if contains(filenames{filename}, 'Mushroom')
            view(-128, -51);
        elseif contains(filenames{filename}, 'Flat')
            view(-197, 32);
        end
        
        [~, name, ~] = fileparts(filenames{filename});
        export_fig([name '_' fields{field}], '-transparent', '-CMYK', '-q101', '-bmp')
    end
end
end

function [x, y, z, values] = matrix_to_xyzv(matrix)
    %flatten the matrix into a vector and return the indices (which serve as xyz coordinates) for each
    %value
    values = matrix(:);
    ind = [1 : numel(values)];
    [x, y, z] = ind2sub(size(matrix), ind);
    %ind2sub gives row vector, whereas everything else is columns vector.
    %Therefore transpose.
    x = x';
    y = y';
    z = z';
end

function [x, y, z, values] = mask_data(x, y, z, values)
    %only keep values that are above 0 for this parameter. Minimum would also be an option, but this gives problems with ZaggSC because the minimum is negative there.
    mask = values > 0;
    x = x(mask);
    y = y(mask);
    z = z(mask);
    values = values(mask);
end