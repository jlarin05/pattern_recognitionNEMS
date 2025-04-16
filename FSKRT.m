function [t, DoM] = FSKRT(test, pattern, delta_omega, overlap, extra, d, s)    
%This function returns the state of an initially-synchronized oscillator
%layer with ring topology, given the pattern memorized by the layer, the input pattern,
%frequency dispersion and coupling strength dispersion
    

    %Set the nonlinearlity of the Duffing oscillator-----------------------
    global lambda
    lambda = 0.1;

   
    %Set the number of oscillators in a network
    N = numel(test);
    

    %Calculate the oscillator's frequencies--------------------------------
    omega_0 = 100;
    omega = omega_0*ones(N, 1);
    for m = 1:N
        omega(m) = omega(m) + delta_omega*(test(m) - pattern(m)) + extra*overlap(m)*(test(m) - pattern(m)) + d*(2*rand() - 1); %the first term is the input frequency shift; 
        %the second is frequency dispersion due to the imperfections in the
        %oscillators
    end
    delta = (omega/omega_0).^2 - 1;

    global rho

    rho_naught = -1.05i;
    rho = rho_naught*ones(1, N); %set the coupling strength


    for l = 1:N
        sigma = s*rho_naught; %take coupling strength dispersion into account
        rho(l) = rho(l) + sigma*(2*rand() - 1);
    end
    %----------------------------------------------------------------------
    

    %Calculate the time evolution of the oscilltor network-----------------
    options = odeset('AbsTol', 10^-6);
    [t, x] = ode45(@Duff, [0 250], ones(96, 1), options);


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



        %The oscillators are arranged in a ring topology: each oscillator
        %is connected to the preceding and the following oscillator
        %The 1st oscillator is connected to 2nd and N-th oscillator; the
        %N-th is connected to (N-1)-th and 1st oscillator
        %Because of this, the lines of code for these 2 oscillators are
        %written out outside of the cycle


        dxdt(1) = -0.5*x(1) + 0.25*x(1)/(abs(x(1))) + lambda*((abs(x(1)))^2)*x(1)*1i + rho(1)*x(N) + rho(2)*x(2) + delta(1)*0.5i;    
        for k = 2:N-1 %k&l were chosen to avoid confusion with the imaginary unit i/j
            dxdt(k) = -0.5*x(k) + 0.25*x(k)/(abs(x(k))) + lambda*((abs(x(k)))^2)*x(k)*1i + rho(k)*x(k-1) + rho(k+1)*x(k+1) + delta(k)*0.5i;    
        end
        dxdt(N) = -0.5*x(N) + 0.25*x(N)/(abs(x(N))) + lambda*((abs(x(N)))^2)*x(N)*1i + rho(N)*x(N-1) + rho(1)*x(1) + delta(N)*0.5i;    


    end

end
