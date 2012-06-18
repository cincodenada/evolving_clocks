function output = clocktest(ck)

%   This is not a completely rigerous simulation of physics.  Since the
%   components are simple and can only connect to each other in defined
%   ways we don't need to performm a full simulation to see what happens.
%   The simulation progresses looking for more and more complex structures.
%   If at any time it finds it is impossible for the clock to tell time,
%   i.e. the gears bind up, there is no spring attached, etc., the
%   simulation stops.  This saves cpu time.

%Structure of a clock matrix
%30 gears:  r 1:30,     c 1:40 connectivity
%           1=connected by teeth
%           2=fused at axil
%           r 1:30,     c 41:100 sum = number teeth
%7 hands:   r 31:37,    c 1:40 connectivity
%1 ratchet  r 38,       c 1:40 connectivity
%1 spring:  r 39,       c 1:40 connectivity
%1 base:    r 40,       c 1:40 connectivity
%

warning('off','all');

output{1} = [];
output{2} = [];
output{3} = [];
output{4} = [];
output{5} = [];

conn = ck(1:40,1:40);
%   Connectivity is bidirectional, make sure the matrix is so.
%   This is just a physical fact of the universe.  If A touches B, B must
%   touch A.  
for r=1:40
    for c=1:40
        if conn(r,c) ~= conn(c,r)
            temp = round(rand(1));
            if temp == 1
                conn(r,c) = conn(c,r);
            else
                conn(c,r) = conn(r,c);
            end
        end
    end
end

gearsize = round(ck(1:30,41)/1e4);
gearsize(gearsize < 4) = 4;

%Gears cannot be connected to more gears than teeth they have. Again, just
%making the simulation physically realistic.
for r=1:30
    g = find(conn(r,1:30) == 1);
    if length(g) > gearsize(r)
        temp = randperm(length(g));
        temp = temp(gearsize(r)+1:length(g));
        conn(r,g(temp)) = 0;
        conn(g(temp),r) = 0;
    end
end

%   Hands can only be connected to max 4 objects because they only have 4
%   connection points.

for r=31:37
    g = find(conn(r,1:40) ~= 0);
    if length(g) > 4
        temp = randperm(length(g));
        temp = temp(5:length(g));
        conn(r,g(temp)) = 0;
        conn(g(temp),r) = 0;
    end
end

%   Ratchet can only be connected to 1 object via its teeth and 2 objects 
%   via its center, again because of the number of connection points.
g = find(conn(38,1:40) == 2);
if length(g) > 1
    temp = randperm(length(g));
    temp = temp(2:length(g));
    conn(38,g(temp)) = 0;
    conn(g(temp),38) = 0;
end
h = find(conn(38,1:40) == 1);
if length(h) > 2
    temp = randperm(length(h));
    temp = temp(3:length(h));
    conn(38,h(temp)) = 0;
    conn(h(temp),38) = 0;
end

%   Spring can only be attached to max 4 objects.  Spring has 2 ends, each
%   end can connect to two objects (1 on each face of the spring.
g = find(conn(39,1:40) ~= 0);
if length(g) > 4
    temp = randperm(length(g));
    temp = temp(5:length(g));
    conn(39,g(temp)) = 0;
    conn(g(temp),39) = 0;
end


for r=1:40
    for c=1:r
        conn(c,r) = conn(r,c);
    end
end

temp99 = ck;
temp99(1:40,1:40) = conn;
output{1} = temp99;

gconn2 = zeros(30);
gconn2(conn(1:30,1:30)==2) = 2;

keep = zeros(30,1);
baseg = find(conn(40,1:30) ~= 0);
keep(baseg) = 1;

%   The circuit_distance.m function finds the shortest path between every 
%   pair of gears.
d2 = circuit_distance(gconn2,baseg);
d2 = d2{1};

for g=1:length(baseg)
    keepg = ~isnan(d2(baseg(g),:));
    keep(keepg==1) = 1;
end

conn(40,keep==1) = 1;

gconn = conn(1:30,1:30);

for r=1:30
    if keep(r) == 0
        gconn(r,:) = 0;
        gconn(:,r) = 0;
    end
end  

%   Check for a pendulum: a hand that is attached to the base
%   that hand may be attached to a gear, but that gear cannot
%   be attached to anything else. In this simple simulation a pendulum is
%   the only form that can create regular motion, this is a simple fact.
%   If we don't find one there is no need to go on as the clock will not
%   work no matter how the remaining components are connected.
p_count = 0;
pend = [];
for h = 31:37
    if conn(40,h) ~= 0
        g = find(conn(h,1:30) ~= 0);
        if length(g) ~= 1
            continue;
        end

        if length(find(conn(g,1:40) ~= 0)) <= 1
            l = (ck(h,41)/1e4);
            if l > 0
                p_count = p_count + 1;
                pend(p_count,1:3) = [h l (2.007 * (l^0.5))];
            end
        end
    end
end

if isempty(pend)
    output{2} = 0;
    output{3} = 0;
    return
end

output{3} = 1;
output{4} = pend;

%   Test for the pendulum(s) ability to tell various intervals of time.
secpend = min(abs(1 - pend(:,3)))/1;
minpend = min(abs(60 - pend(:,3)))/60;
hrpend = min(abs(3600 - pend(:,3)))/3600;
daypend = min(abs(86400 - pend(:,3)))/86400;
weekpend = min(abs(604800 - pend(:,3)))/604800;
yearpend = min(abs(31536000 - pend(:,3)))/31536000;

score(1) = 1/secpend;
score(2) = 1/minpend;
score(3) = 1/hrpend;
score(4) = 1/daypend;
score(5) = 1/weekpend;
score(6) = 1/yearpend;

if min(pend(:,3)) > 31536000
    score(1:6) = 0;
elseif min(pend(:,3)) > 604800
    score(1:5) = 0;
elseif min(pend(:,3)) > 86400
    score(1:4) = 0;
elseif min(pend(:,3)) > 3600
    score(1:3) = 0;
elseif min(pend(:,3)) > 60
    score(1:2) = 0;
elseif min(pend(:,3)) > 1
    score(1) = 0;
end

%   Prevent scores of infinity.
score(score > 1e6) = 1e6;
output{2} = sum(score);
  
%   Let's search foward from the pendulum.  The only way a pendulum can
%   transfer motion to gears is through a ratchet.  We are not constraining
%   who connects where but if things don't line up in a functional way the
%   clock won't work and there is no need continuing the simulation.  We
%   onlt simulate as far as we need to go. This saves computer time and
%   makes the code more compact.
g = [];
gr = [];
gs = [];
for p = 1:size(pend,1)
    if conn(38,pend(p,1)) == 1
        %The ratchet connects to the pendulum.
        %This is the gear the pendulum ratchet connects to
        gr = find(conn(38,1:30) == 2);
        if length(gr) > 1
            gr = gr(1);
        end
        
        if conn(40,gr) == 0
            %The gear does not connect to the base.
            gr = [];
        end
        
        if ~isempty(gr)
            %This is the gear the spring connects to
            gs = find(conn(39,1:30) ~= 0);
            if length(gs) > 1
                gs = gs(1);
            end
            
            if conn(40,gs) == 0
                gs = [];
            end
            pendulum = p;
        end 
    end
end
        
if ~isempty(gr) && ~isempty(gs)
    d2 = circuit_distance(gconn,[gr gs]);
    d2 = d2{1};
    
    if ~isnan(d2(gr,gs)) || gs == gr
        %The spring gear connects to the ratchet gear
    else
        output{3} = 2;
        return
    end
else
    return
end
output{3} = 3;
%   If you made it here you potentially have a powered clock
%   must check if the gears turn or if they bind up.
%   Start with the ratcheted gear and work foward to all gears it
%   is connected to.  Initial turn rate is 0, the values are updated
%   as you work through the connections.  If a value to be assigned to 
%   a gear conflicts with a value already there (except 0) that means 
%   the system will not turn.
    
rotation = zeros(30,1);
period = pend(pendulum,3) * gearsize(gr);
period = (round(period * 1e3)) / 1e3;
rotation(gr) = period;
pathlength = 1;
s = gr;
        
while pathlength > 0   
    nn = s(pathlength);
    post = find(gconn(nn,:) ~= 0);
    
    badgears = 0;
    foundtip = 0;
    for test = 1:length(post)
        if gconn(nn,post(test)) == 2
            temprot = rotation(nn);
        else
            temprot = -rotation(nn) * (gearsize(post(test))/gearsize(nn));
        end
        
        temprot = (round(temprot * 1e3)) / 1e3;
        
        if rotation(post(test)) == 0
            rotation(post(test)) = temprot;
            s = [s post(test)];
            pathlength = pathlength + 1;
            foundtip = 1;
            break;
        elseif abs(rotation(post(test)) - temprot) > 0.002
            badgears = 1;
            break
            
        end
    end
    
    if badgears == 1
        %disp('gears');
        break;
        
    end
        
    if  isempty(test) && foundtip == 0
        s = s(1:length(s)-1);
        pathlength = pathlength - 1;
    elseif test == length(post) && foundtip == 0
        s = s(1:length(s)-1);
        pathlength = pathlength - 1;
    end
end

%   There are other ways gears can bind.  First check if a hand 
%   connects to two different gears.  At least one must be spinning.

for r=31:37
    o = find(conn(r,1:40) ~= 0);
    if length(o) > 1
        g = find(conn(r,1:30) ~= 0);
        for temp = 1:length(g)
            if rotation(g(temp)) ~= 0
                badgears = 1;
                %disp('hands');
            end
        end
    end
end

%   The spring was previously determined to connect to one gear and
%   the housing, therefore the spring cannot bind up the gears.
%   The ratchet was also previously tested.

if badgears == 1
    return
end

output{3} = 4;
%   If you make it here then the gears do not bind.  Find the hands
%   are attached to the gears that move and calculate their period
%   moving hands beat out pendulums.  Multiply their scores by 1000.

spinrate = rotation(rotation ~= 0);

%   Here we test the gears ability to measure various intervals of time.
%   Gears usually beat pendulums since they can spin at much slower rates.
secgear = min(abs(1-abs(spinrate)))/1;
mingear = min(abs(60-abs(spinrate)))/60;
hrgear = min(abs(3600-abs(spinrate)))/3600;
daygear = min(abs(86400-abs(spinrate)))/86400;
weekgear = min(abs(604800-abs(spinrate)))/604800;
yeargear = min(abs(31536000-abs(spinrate)))/31536000;

if score(1) < abs(1/secgear)
    score(1) = abs(1/secgear);
end
if score(2) < abs(1/mingear)
    score(2) = abs(1/mingear);
end
if score(3) < abs(1/hrgear)
    score(3) = abs(1/hrgear);
end
if score(4) < abs(1/daygear)
    score(4) = abs(1/daygear);
end
if score(5) < abs(1/weekgear)
    score(5) = abs(1/weekgear);
end
if score(6) < abs(1/yeargear)
    score(6) = abs(1/yeargear);
end

%   Gears cannot keep time below the period of the pendulum.  This feature
%   might have been added after I made the video.
if pend(pendulum,3) > 31536000
    score(1:6) = 0;
elseif pend(pendulum,3) > 604800
    score(1:5) = 0;
elseif pend(pendulum,3) > 86400
    score(1:4) = 0;
elseif pend(pendulum,3) > 3600
    score(1:3) = 0;
elseif pend(pendulum,3) > 60
    score(1:2) = 0;
elseif pend(pendulum,3) > 1
    score(1) = 0;
end
    
score(score > 1e6) = 1e6;
output{2} = sum(score);

spinners = find(rotation ~= 0);
hands = [];
handcount = 0;

%   Look for hands connected to the gears.
for h=31:37
    temphand = find(conn(h,spinners) ~= 0);
    if ~isempty(temphand)
        if conn(40,h) == 0
            handcount = handcount + 1;
            hands(handcount,1:3) = [h spinners(temphand) rotation(spinners(temphand))];
    
        end
    end
end

if isempty(hands)
    return
end
output{3} = 5;
output{5} = hands;

%   Test the hands ability to measure various periods of time.
hs = abs(1 - abs(hands(:,3)))/1;
hm = abs(60 - abs(hands(:,3)))/60;
hh = abs(3600 - abs(hands(:,3)))/3600;
hd = abs(86400 - abs(hands(:,3)))/86400;
hw = abs(604800 - abs(hands(:,3)))/604800;
hy = abs(31536000 - abs(hands(:,3)))/31536000;

sechand = min(hs);
minhand = min(hm);
hrhand = min(hh);
dayhand = min(hd);
weekhand = min(hw);
yearhand = min(hy);

temp = find(hs == sechand);
handuse(1) = temp(1);

temp = find(hm == minhand); 
handuse(2) = temp(1);

temp = find(hh == hrhand);
handuse(3) = temp(1);

temp = find(hd == dayhand);
handuse(4) = temp(1);

temp = find(hw == weekhand);
handuse(5) = temp(1);

temp = find(hy == yearhand);
handuse(6) = temp(1);

uniquehand = length(unique(handuse));

score(1) = abs(1/sechand);
score(2) = abs(1/minhand);
score(3) = abs(1/hrhand);
score(4) = abs(1/dayhand);
score(5) = abs(1/weekhand);
score(6) = abs(1/yearhand);

if pend(pendulum,3) > 31536000
    score(1:6) = 0;
elseif pend(pendulum,3) > 604800
    score(1:5) = 0;
elseif pend(pendulum,3) > 86400
    score(1:4) = 0;
elseif pend(pendulum,3) > 3600
    score(1:3) = 0;
elseif pend(pendulum,3) > 60
    score(1:2) = 0;
elseif pend(pendulum,3) > 1
    score(1) = 0;
end


%   As mentioned in the video, hands on gears are much better than gears
%   alone since they allow you to keep track of the exact position of the
%   gear.  This way you can look away from the clock and not loose the
%   time.  Hands therefore make the clock much better at telling time.
%   QUestion is how much better.  Here I multiply the score by 1 million
%   since I think hands improve them that much (clocks that you have to
%   stare at all the time are pretty crappy), but this value is subjective.
%   Play with it and see what happens.
score(score > 1e6) = 1e6;
output{2} = sum(score) * 1e6;

output{3} = 4 + uniquehand;

%output{6} = gconn;



    