function [t, DoM] = FSKBT_noisy(test, pattern, epsilon)    
%This function returns the state of an initially-synchronized oscillator
%layer with all-to-all coupling, given the pattern memorized by the layer, the input pattern,
%and noise levels. Frequency dispersion and coupling strength dispersion
%can additionally be specified in the function body


%!!!NB: THIS CODE REQUIRES AN SDE EQUATION SOLVER!!! 
%IT IS AVAILABLE AT: https://github.com/horchler/SDETools?tab=readme-ov-file 
    

    %Set the nonlinearlity of the Duffing oscillator-----------------------
    global lambda
    lambda = 0.35;

    
    %Set the number of oscillators in a network
    N = numel(test);
    

    %Calculate the oscillator's frequencies--------------------------------
    omega_0 = 100;
    omega = omega_0*ones(N, 1);
    delta_omega = 20;
    d = 0; %change to modify the frequency dispersion
    for m = 1:N
        omega(m) = omega(m) + delta_omega*(test(m) - pattern(m)) + d*(2*rand() - 1); %the first term is the input frequency shift; 
        %the second is frequency dispersion due to the imperfections in the
        %oscillators
    end
    delta = (omega/omega_0).^2 - 1; 


    %specify the parameters for the Euler-Heun solver: dt is the time step;
    %t is thus an array of times at which the system state is calculated; g
    %is the white Gaussian noise function
    dt = 1e-2;
    t = 0:dt:200;
    g = @(t, x)epsilon;
    %--------------------------------------------------------------------------
    

    %Calculate the time evolution of the oscilltor network using the
    %Euler-Heun method
    %More info about sde_euler available at: 
    %https://github.com/horchler/SDETools/blob/master/SDETools/sde_euler.m
    x = sde_euler(@Duff, g, t, ones(96, 1));
    DoM = abs(mean(x'));


    %Find the degree of match between an initial layer state (complete synchronization)
    %and its state at time t
    %This effectively measures the degree of its synchronization on a 0-1
    %scale
%     T = numel(t);
%     DoM = zeros(T, 1);
%     for n = 1:T
%         DoM(n) = degree_of_match(exp(angle(x(n, 1:N))*1i), ones(96, 1));
%     end
%     
    
    %Simulate the network web--------------------------------------------------
    function dxdt =  Duff(t, x)
    %The differential equation for the oscillator's amplitude
        dxdt = zeros(N, 1); %preallocate oscillator velocities


        %In the FSKAAC, the output signal of all oscillators is averaged
        %and 'fed' back into the oscillators
        %Below, the average output is calculated
        average = 0;


        s = 0; %change to specify the coupling strength dispersion


        for k = 1:N
            rho = 0.5; %set the coupling strength
            sigma = s*rho; %take coupling strength dispersion into account
            rho = rho + sigma*(2*rand() - 1);
            average = average + rho*x(k);
        end
        average = average/N; 


        for k = 1:N %k&l were chosen to avoid confusion with the imaginary unit i/j
            %Find the velocity of k-th oscillator
            rho = 0.5;
            sigma = s*rho;
            rho = rho + sigma*(2*rand() - 1);
            dxdt(k) = -0.5*x(k) + 0.25*x(k)/(abs(x(k))) + lambda*((abs(x(k)))^2)*x(k)*1i + rho*average + delta(k)*0.5i;    
        end
        
    end


end