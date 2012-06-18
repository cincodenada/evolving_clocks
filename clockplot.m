function output = clockplot

%This function compiles the data out of every population file in a single
%folder, considered 1 independent evolution.  The output can then be passed
%to clockplot2.m for better display.

p = uigetdir;
g = 1;
f = '/Generation 1.mat';
output = zeros(1e3,8);

while exist([p f],'file')

    disp(['Loading Generation ',num2str(g),'...']);
    load([p f]);
    
    temp = zeros(length(pop),1);
    
    for c=1:length(pop)
        temp(c) = pop{c}{3};
    end
    
    output(g,1) = length(find(temp == 1)) / length(pop);
    output(g,2) = length(find(temp == 2)) / length(pop);
    output(g,3) = length(find(temp == 3)) / length(pop);
    output(g,4) = length(find(temp == 4)) / length(pop);
    output(g,5) = length(find(temp == 5)) / length(pop);
    output(g,6) = length(find(temp == 6)) / length(pop);
    output(g,7) = length(find(temp == 7)) / length(pop);
    output(g,8) = length(find(temp == 8)) / length(pop);
    output(g,9) = (1 - sum(output(g,1:8)));
    
    %if g == 5
    %    break;
    %end
    g = g+1;
    f = ['/Generation ',num2str(g),'.mat'];
    
end

plot(output);
        
