function dydt = seir_model(t,y,pars)
% function dydt = seir_model(t,y,pars)

S=y(1);
E=y(2);
I=y(3);
R=y(4);

dydt=zeros(4,1);

dydt(1)=-pars.beta*I*S;
dydt(2)=pars.beta*I*S-pars.eta*E;
dydt(3)=pars.eta*E-pars.gamma*I-pars.sens*I/pars.tau;
dydt(4)=pars.gamma*I+pars.sens*I/pars.tau;

