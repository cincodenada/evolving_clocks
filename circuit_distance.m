function x = circuit_distance(c,primarynodes)

if nargin == 1    
    primarynodes = 1:length(c);
end

d = ones(size(c));
dtemp = ones(length(c),1) * 1e6;
pathmat{size(c,1),size(c,2)} = [];
%xxx = waitbar(0,'Searching for Paths');

%postmat{1:length(c)} = [];
for i = 1:length(c)
    postmat{i} = find(c(i,:) ~= 0);
end

for N = 1:length(c)
    
    if isempty(primarynodes(primarynodes == N));
        continue;
    end
    
    %if rem(N,5) == 0
    %    waitbar(N/length(c));
    %end
    clear s
    clear nn
    clear post
    
    s = N;
    pathlength = 1;
    
    while pathlength > 0   
        nn = s(pathlength);
        post = postmat{nn};
        
        foundtip = 0;
        for test = 1:length(post)
            if dtemp(post(test)) > pathlength
                dtemp(post(test)) = pathlength;
                pathmat{N,post(test)} = [s post(test)];
                s = [s post(test)];
                pathlength = pathlength + 1;
                foundtip = 1;
                break;
            end
        end
        
        if  isempty(test) && foundtip == 0
            s = s(1:length(s)-1);
            pathlength = pathlength - 1;
        elseif test == length(post) && foundtip == 0
            s = s(1:length(s)-1);
            pathlength = pathlength - 1;
        end
    end

    d(N,:) = dtemp;
    dtemp = ones(length(c),1) * 1e6;
    
end

d(d == 1e6) = NaN;

x{1} = d;
x{2} = pathmat;

%close(xxx);
