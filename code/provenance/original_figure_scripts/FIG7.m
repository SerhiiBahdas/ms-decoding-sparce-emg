%% A

close all; clear all; clc

load('FIG7_A_filt.mat')

tProcessing = tProcessing(1001:6000);

f = figure; 

f.Position = [100 100 100 250];

violinplot(ones(size(tProcessing)),tProcessing)

hold on;

s = swarmchart(ones(size(tProcessing)),tProcessing);
s.SizeData = 1;

disp("MEDIAN:" + round(median(tProcessing),4))
disp("MEAN:" + round(mean(tProcessing),4))
disp("STD:" + round(std(tProcessing),4))



hold on; 

bch = boxchart(ones(size(tProcessing)),tProcessing, 'BoxFaceColor', 'k'); 
bch.MarkerStyle = 'none';

disp("--------")

%% B

load('FIG7_B_decod_all4.mat')

tDecoding = tDecoding(1001:6000);

f = figure; 

f.Position = [100 100 100 250];

violinplot(ones(size(tDecoding)),tDecoding)

hold on;

s = swarmchart(ones(size(tDecoding)),tDecoding);
s.SizeData = 1;


disp("MEDIAN:" + round(median(tDecoding),4))
disp("MEAN:" + round(mean(tDecoding),4))
disp("STD:" + round(std(tDecoding),4))

hold on; 

bch = boxchart(ones(size(tDecoding)),tDecoding, 'BoxFaceColor', 'k'); 
bch.MarkerStyle = 'none';

ylim([-1e-3, 40e-3])

disp("--------")

%%

load('FIG7_C_decod_prox.mat')

tDecoding = tDecoding(1001:6000);

f = figure; 

f.Position = [100 100 100 250];

violinplot(ones(size(tDecoding)),tDecoding)

hold on;

s = swarmchart(ones(size(tDecoding)),tDecoding);
s.SizeData = 1;


disp("MEDIAN:" + round(median(tDecoding),4))
disp("MEAN:" + round(mean(tDecoding),4))
disp("STD:" + round(std(tDecoding),4))



hold on; 

bch = boxchart(ones(size(tDecoding)),tDecoding, 'BoxFaceColor', 'k'); 
bch.MarkerStyle = 'none';

ylim([-1e-3, 40e-3])

disp("--------")

%%

load('FIG7_D_decod_dist2.mat')

tDecoding = tDecoding(1001:6000);

f = figure; 

f.Position = [100 100 100 250];

violinplot(ones(size(tDecoding)),tDecoding)

hold on;

s = swarmchart(ones(size(tDecoding)),tDecoding);
s.SizeData = 1;


disp("MEDIAN:" + round(median(tDecoding),4))
disp("MEAN:" + round(mean(tDecoding),4))
disp("STD:" + round(std(tDecoding),4))



hold on; 

bch = boxchart(ones(size(tDecoding)),tDecoding, 'BoxFaceColor', 'k'); 
bch.MarkerStyle = 'none';

ylim([-1e-3, 40e-3])

disp("--------")