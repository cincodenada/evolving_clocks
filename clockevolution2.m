function scoremat = clockevolution2(g)

%This is the function that performs the evolution.  It builds, tests,
%mates, and saves each population of clocks to a file on your computer.
%Testing is done by the function clocktest.m

warning('off','all');

N = 1e4;
%scoremat = zeros(N,g);

answer = questdlg('Do you want to start from a previous saved generation?');

if strcmp(answer,'Yes')
    [f p] = uigetfile;
    load([p f]);
    stop = 0;
    count = 12;
    while stop == 0
        count = count + 1;
        if strcmp(f(count),'.')
            count = count-1;
            stop = 1;
        end
    end
    startgen = str2num(f(12:count));
    
    if isempty(pop{1}{1})
        disp('This file does not contain clock matrixes');
        return
    end
    
    pop1 = pop;
    pop2 = pop;
    
    for c=1:N
        pop2{c}{1} = [];
    end

    
elseif strcmp(answer,'No')

    startgen = 1;
    p = uigetdir;
    
    for c=1:N
        ck = rand(40,41);
        ck(ck<0.06) = 1;
        ck(ck<0.1) = 2;
        ck(ck<1) = 0;
        ck(:,41) = round(rand(40,1) * 1e6);
        
        output = clocktest(ck);
        
        pop1{c}{1} = (output{1});
        pop1{c}{2} = output{2};
        pop1{c}{3} = output{3};
        pop1{c}{4} = output{4};
        pop1{c}{5} = output{5};
        
        pop2{c}{1} = [];
        pop2{c}{2} = output{2};
        pop2{c}{3} = output{3};
        pop2{c}{4} = output{4};
        pop2{c}{5} = output{5};
    end
    
    pop = pop1;
    f = ['\Generation 1.mat'];
    save([p f],'pop');
    
else 
    return
end

for gen = startgen+1:startgen+g
    disp(gen);
    pause(0.1);
    for battle=1:N     
        clocks = ceil(rand(3,1) * N);
        
        while length(unique(clocks)) < 3
            clocks = ceil(rand(3,1) * N);
        end

        tempscore = zeros(3,2);
        for c=1:3
            tempscore(c,1) = pop1{clocks(c)}{2};
            tempscore(c,2) = clocks(c);
        end
        rankscore = sortrows(tempscore,-1);
        dead = rankscore(3,2);
        pop1{dead} = [];
        pop2{dead} = [];
        
        mother = pop1{rankscore(1,2)}{1};
        father = pop1{rankscore(2,2)}{1};
        
        parent = round(rand(40,41));
        
        offspring = zeros(40,41);
        offspring(parent==0) = mother(parent==0);
        offspring(parent==1) = father(parent==1);
        
        one = 0.05;
        two = 0.05;
        
        for m=1:2
            
            mutloc = ceil(rand(1) * 1640);
            mut = rand(1);
            
            if mut <= one
                mut = 1;
            elseif mut <= one + two
                mut = 2;
            else
                mut = 0;
            end
            if mutloc > 1600
                offspring(mutloc) = round(rand(1) * 1e6);
            else
                offspring(mutloc) = mut;
            end
        end

        output = clocktest(offspring);
            
        pop1{dead}{1} = (output{1});
        pop1{dead}{2} = output{2};
        pop1{dead}{3} = output{3};
        pop1{dead}{4} = output{4};
        pop1{dead}{5} = output{5};
        
        pop2{dead}{1} = [];
        pop2{dead}{2} = output{2};
        pop2{dead}{3} = output{3};
        pop2{dead}{4} = output{4};
        pop2{dead}{5} = output{5};
    end
    
    score = zeros(N,1);
    tally = zeros(N,1);
    for c=1:N
        score(c) = pop1{c}{2};
        tally(c) = pop1{c}{3};
    end
    
    types(1) = length(find(tally == 1)); %pendulum
    types(2) = length(find(tally == 2)); %ratchet, spring gear not conn
    types(3) = length(find(tally == 3)); %ratchet, spring gear connected
    types(4) = length(find(tally == 4)); %proto-clock
    types(5) = length(find(tally == 5)); %one unique hand
    types(6) = length(find(tally == 6)); %two unique hands
    types(7) = length(find(tally == 7)); %three unique hands
    types(8) = length(find(tally == 8)); %four unique hands
    types(9) = length(find(tally == 9));
    types(10) = length(find(tally == 10));

    disp(types);
    
    %scoremat(:,gen) = score;
    scoremat = [];

    f = ['\Generation ',num2str(gen),'.mat'];
    
    if rem(gen,10) == 0
        pop = pop1;
    else
        pop = pop2;
    end 
        
    save([p f],'pop');
end









