
numk = 3;       % number of item types
W = 10;         % total bag weight limit
%c = 26;         % satisfiable return threshold
w = [1 2 3];    % item weight by type
mu= [2 5 8];    % mean of item return by type
v = [1 3 6];    % variance of item return by type

% Solve DKP for different values of c.
fprintf('   c   p*  mu*   v*   w* -x-\n');
for c = 24:30
    [popt, x] = DSKPsolve(numk,W,w,mu,v,c,false);
    fprintf('%4d %4.2f %4d %4d %4d [%s]\n',...
        c,popt,sum(mu.*x),sum(v.*x),sum(w.*x),...
        sprintf('%d ',x));
end
