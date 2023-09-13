
%% Study 1 (speed vs. accuracy)
% NDT
NDT = 0.3171
% Speed
disp("Speed")
driftrate = 2.3988;
threshold = 0.7053;
[W1,W2] = estimateRPByVAFull(driftrate,threshold,NDT, @(x1,x2) x1.^2,@(x1,x2) 0, @(x1,x2) 2*x1,0)
% Accuracy
disp("Accuracy")
driftrate = 2.9618;
threshold = 1.1687;
[W1,W2] = estimateRPByVAFull(driftrate,threshold,NDT, @(x1,x2) x1.^2,@(x1,x2) 0, @(x1,x2) 2*x1,0)


%% Study 2 (speed vs. accuracy vs. speed & accuracy)
% NDT
NDT = 0.3316689
% Speed
disp("Speed")
driftrate = 2.7223633;
threshold = 0.6128029;
[W1,W2] = estimateRPByVAFull(driftrate,threshold,NDT, @(x1,x2) x1.^2,@(x1,x2) 0, @(x1,x2) 2*x1,0)
% Accuracy
disp("Accuracy")
driftrate = 3.5649336;
threshold = 1.1493433;
[W1,W2] = estimateRPByVAFull(driftrate,threshold,NDT, @(x1,x2) x1.^2,@(x1,x2) 0, @(x1,x2) 2*x1,0)
% Speed & Accuracy
disp("Speed & Accuracy")
driftrate = 3.2469639;
threshold = 0.9239954;
[W1,W2] = estimateRPByVAFull(driftrate,threshold,NDT, @(x1,x2) x1.^2,@(x1,x2) 0, @(x1,x2) 2*x1,0)

%% Study 3 (SOA)
% NDT
NDT = 0.3903721

% Speed - Fixed
disp("Speed")
driftrate = 2.9756796;
threshold = 0.8063992;
[W1,W2] = estimateRPByVAFull(driftrate,threshold,NDT, @(x1,x2) x1.^2,@(x1,x2) 0, @(x1,x2) 2*x1,0)
% Accuracy - Fixed
disp("Accuracy")
driftrate = 3.1341511;
threshold = 1.0240746;
[W1,W2] = estimateRPByVAFull(driftrate,threshold,NDT, @(x1,x2) x1.^2,@(x1,x2) 0, @(x1,x2) 2*x1,0)


%% Study 4 (swtich frequency)
% NDT
NDT = 0.3831758
disp("Fixed block")
% Speed - Fixed
disp("Speed")
driftrate = 3.1603927;
threshold = 0.7374816;
[W1,W2] = estimateRPByVAFull(driftrate,threshold,NDT, @(x1,x2) x1.^2,@(x1,x2) 0, @(x1,x2) 2*x1,0)
% Accuracy - Fixed
disp("Accuracy")
driftrate = 3.5231782;
threshold = 1.0434840;
[W1,W2] = estimateRPByVAFull(driftrate,threshold,NDT, @(x1,x2) x1.^2,@(x1,x2) 0, @(x1,x2) 2*x1,0)


