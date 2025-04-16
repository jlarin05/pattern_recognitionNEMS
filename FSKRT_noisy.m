function [t, DoM] = network_simulation(test, pattern, overlap, extra, epsilon)    
%This function returns the state of an initially-synchronized oscillator
%layer with ring topology coupling, given the pattern memorized by the layer, the input pattern,
%and noise levels. Frequency dispersion and coupling strength dispersion
%can additionally be specified in the function body



%!!!NB: THIS CODE REQUIRES AN SDE EQUATION SOLVER!!! 
%IT IS AVAILABLE AT: https://github.com/horchler/SDETools?tab=readme-ov-file 
    

    %Set the nonlinearlity of the Duffing oscillator-----------------------
    global lambda
    lambda = 0.1;

    
    %Set the number of oscillators in a network
    N = numel(test);


    %Calculate the oscillator's frequencies--------------------------------
    omega_0 = 100;
    omega = omega_0*ones(N, 1);
    delta_omega = 12.5;
    d = 0; %change to modify the frequency dispersion
    for m = 1:N
        omega(m) = omega(m) + delta_omega*(test(m) - pattern(m)) + extra*overlap(m)*(test(m) - pattern(m)) + d*(2*rand() - 1); %the first term is the input frequency shift; 
        %the second is frequency dispersion due to the imperfections in the
        %oscillators
    end
    delta = (omega/omega_0).^2 - 1; 


    %specify the parameters for the Euler-Heun solver: dt is the time step;
    %t is thus an array of times at which the system state is calculated; g
    %is the white Gaussian noise function
    dt = 1e-3;
    t = 0:dt:200;
    g = @(t, x)epsilon;
    %--------------------------------------------------------------------------
    

    %Calculate the time evolution of the oscilltor network using the
    %Euler-Heun method
    %More info about sde_euler available at: 
    %https://github.com/horchler/SDETools/blob/master/SDETools/sde_euler.m
    x = sde_euler(@Duff, g, t, ones(96, 1));


    %When the oscilations in the ring cease, its DoM plummets to 0; but if it
    %keeps oscillating, the DoM > 0.20. This makes DoM a useful proxy for ring oscillations
    T = numel(t);
    DoM = zeros(T, 1);
    for n = 1:T
        DoM(n) = degree_of_match(exp(angle(x(n, 1:N))*1i), ones(96, 1));
    end
    
    
     %Simulate the network web--------------------------------------------------
    function dxdt =  Duff(t, x)
    %The differential equation for the oscillator's amplitude


        dxdt = zeros(N, 1); %pre-allocate the velocity array

        rho = -1.05i; %specify the coupling strength


        %The oscillators are arranged in a ring topology: each oscillator
        %is connected to the preceding and the following oscillator
        %The 1st oscillator is connected to 2nd and N-th oscillator; the
        %N-th is connected to (N-1)-th and 1st oscillator
        %Because of this, the lines of code for these 2 oscillators are
        %written out outside of the cycle


        dxdt(1) = -0.5*x(1) + 0.25*x(1)/(abs(x(1))) + lambda*((abs(x(1)))^2)*x(1)*1i + rho*x(N) + rho*x(2) + delta(1)*0.5i;    
        for k = 2:N-1 %k&l were chosen to avoid confusion with the imaginary unit i/j
            dxdt(k) = -0.5*x(k) + 0.25*x(k)/(abs(x(k))) + lambda*((abs(x(k)))^2)*x(k)*1i + rho*x(k-1) + rho*x(k+1) + delta(k)*0.5i;    
        end
        dxdt(N) = -0.5*x(N) + 0.25*x(N)/(abs(x(N))) + lambda*((abs(x(N)))^2)*x(N)*1i + rho*x(N-1) + rho*x(1) + delta(N)*0.5i;    


    end


end