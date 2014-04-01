function [popt x] = DSKPsolve(numk,W,w,mu,v,c, displayInfo)
% Stochastic Knapsack Solver via Dynamic Programming
% max P[ r*x >= c ] via
% min (x - mu*x)/sqrt(v*x)

% inputs
if nargin == 0
    % use default values if none given
    numk = 3;       % number of item types
    W = 10;         % total bag weight limit
    c = 26;         % satisfiable return threshold
    w = [1 2 3];    % item weight by type
    mu= [2 5 8];    % mean of item return by type
    v = [1 3 6];    % variance of item return by type
    displayInfo = true;
elseif nargin < 6
    error('not enough input arguments');
elseif nargin == 6
    displayInfo = true;
end


%muPerW = mu ./ w;   % mean return per weight by type
vPerW = v ./ w;     % variance per weight by type
wlow = min(w);      % lowest possible weight (highest is W)
vlow = min(v);
vhigh = max( vPerW * W ); % conservative upper bound on v, if we put in 
                    %only items of the type with highest variance per weight
f = DPmap();
k = DPmap();
f(0,0) = 0;

% compute k(w,v) and f(w,v) for each feasible (w,v)
for wcur = wlow:W
    for vcur = vlow:vhigh;
        % Backward recursion step
        % select item that results in greatest increase to mu, from current
        % weight w and variance v, backward
        % Original version
%         kbest = 1;
%         fbest = f(wcur-w(1), vcur-v(1)) + mu(1);
%         for kcur = 2:numk
%             fcur = f(wcur-w(kcur), vcur-v(kcur)) + mu(kcur);
%             if fcur > fbest
%                 fbest = fcur;
%                 kbest = kcur;
%             end
%         end
        % Optimized version
        fvals = arrayfun(@(kcur) f(wcur-w(kcur), vcur-v(kcur)) + mu(kcur), 1:numk);
        [fbest, kbest] = max(fvals);
        k(wcur,vcur) = kbest;
        f(wcur,vcur) = fbest;
    end
end

% Phase 2
% determine optimal objective value rho(w) for each feasible w
% (take the v that gives the lowest rho for each w)
% rho = (c-f(w,v))/sqrt(v)
% rho maps w -> objective value
% (actual probability is 1-normcdf(rho))
rho = containers.Map('KeyType','int32','ValueType','double');
% k1 maps w -> the kind with the best v for optimal rho
k1 = containers.Map('KeyType','int32','ValueType','int32');
for wcur = wlow:W
    rhovals = arrayfun(@(vcur) (c-f(wcur,vcur))/sqrt(vcur), vlow:vhigh);
    [rhobest, vbest] = min(rhovals);
    rho(wcur) = rhobest;
    k1(wcur) = k(wcur,vbest);
end

% Phase 3 (Adapted)
% which weight gives the lowest rho?
% we expect W yields the lowest rho, but it may be a different w'
[rhoopt, wopt] = minMap1(rho);
popt = 1-normcdf(rhoopt);
% now construct x backward from wopt downto 0
x = zeros(1,numk);
wcur = wopt;
while wcur ~= 0
    x(k1(wcur)) = x(k1(wcur)) + 1;
    wcur = wcur - w(k1(wcur));
end

if displayInfo
    fprintf('Optimal w* = %d; rho* = %.2f; p* = %.2f\n', ...
        wopt, rhoopt, popt);
    fprintf('Bag mean = %d; Bag variance = %d\n',sum(x.*mu),sum(x.*v));
    fprintf('Fill your knapsack with these items:\n');
    disp(x);
end

end % function
