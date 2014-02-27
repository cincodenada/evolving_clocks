function x = circuit_distance(c,primarynodes)
%   c = gear connections
%   primarynodes = those connected to housing

%   If no primary nodes, assume all are connected (?)
if nargin == 1
    primarynodes = 1:length(c);
end

dist = ones(size(c));
curdist = ones(length(c),1) * 1e6;
pathmat{size(c,1),size(c,2)} = [];
%xxx = waitbar(0,'Searching for Paths');

%   For each gear, get a list of gears that are
%   somehow connected to it
%myconnsmat{1:length(c)} = [];
for i = 1:length(c)
    myconnsmat{i} = find(c(i,:) ~= 0);
end

for pgear = 1:length(c)
    
    % If this gear isn't connected to the housing,
    % Skip it
    % TODO: This limits found paths to end nodes, is that okay?
    if isempty(primarynodes(primarynodes == pgear));
        %continue;
    end
    
    % Update the waitbar
    if rem(pgear,5) == 0
        waitbar(pgear/length(c));
    end

    clear csteps 
    clear nn
    clear myconns
    
    % Initialize csteps to this gear
    csteps = pgear;
    pathlength = 1;
    
    while pathlength > 0
        cgear = csteps(pathlength);
        myconns = myconnsmat{cgear};
        
        foundtip = 0;
        for curtest = 1:length(myconns)
            curconn = myconns(curtest);
            if curconn==pgear
                continue;
            end
            % If we've found a path shorter than the shortest
            % Then update the path matrix
            if curdist(curconn) > pathlength
                curdist(curconn) = pathlength;
                pathmat{pgear,curconn} = [csteps curconn];
                csteps = [csteps curconn];
                pathlength = pathlength + 1;
                foundtip = 1;
                break;
            end
        end
        
        if  isempty(curtest) && foundtip == 0
            csteps = csteps(1:length(csteps)-1);
            pathlength = pathlength - 1;
        elseif curtest == length(myconns) && foundtip == 0
            csteps = csteps(1:length(csteps)-1);
            pathlength = pathlength - 1;
        end
    end

    dist(pgear,:) = curdist;
    curdist = ones(length(c),1) * 1e6;
    
end

for r = 1:size(pathmat,1)
    for c = (r+1):size(pathmat,2)
        if isempty(pathmat{r,c})
            pathmat{r,c} = fliplr(pathmat{c,r}) 
        elseif isempty(pathmat{c,r})
            pathmat{c,r} = fliplr(pathmat{r,c})
        end
    end
end

dist(dist == 1e6) = NaN;

x{1} = dist;
x{2} = pathmat;

%close(xxx);
