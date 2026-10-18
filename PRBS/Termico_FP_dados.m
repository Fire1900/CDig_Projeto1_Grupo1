% Prj1CDig_m
%
% Controle PI Anti-WindUp de Processo Térmico
%
% @AB ENE/UnB Condrole Digital

% resposta do processo térmico ao sinal PRBS
load ma31500

%% 1. Parâmetros Físicos Identificados (Modelo P2DZ - Grupo 1)
% Convenção do Roteiro: Tp1 = Lento (ambiente), Tp2 = Rápido (aquecimento)
Kp  = 0.1239;     % Ganho estático do processo (ºC / PWM)
Tp1 = 449.04;    % Constante de tempo LENTA (ambiente) em segundos
Tp2 = 31.96;     % Constante de tempo RÁPIDA (aquecimento) em segundos
Tz  = 367.32;    % Zero térmico em segundos
Td  = 6.67;      % Atraso de transporte (tempo morto) em segundos
Ta  = 23.5;        % Temperatura Ambiente (ºC)
PO  = 45;        % Ponto de Operação do Grupo 1 (ºC)

%% 2. Parâmetros da Perturbação do Cooler (Grupo 1)
w0    = 0.06544984694979; % Frequência da perturbação do cooler (rad/s)
AmpW0 = 0.02;             % Amplitude da perturbação

%% 3. Decomposição Modal em Frações Parciais (Bloco 'Processo Térmico')
Am = (Tz - Tp1) / (Tp2 - Tp1); % Peso do modo lento Tp1 (Am = 0.1959)
Bm = 1 - Am;                   % Peso do modo rápido Tp2 (Bm = 0.8041)

%% 4. Ganhos do Controlador PI Contínuo (Ajustados no Passo 4 / SISOTOOL)
KP = 33.2;                     % Ganho Proporcional
KI = KP / Tp2;                 % Ganho Integral (KI = 1.0388 - cancela Tp2)

%% 5. Período de Amostragem do Controle Digital (Ts = Td / 2)
Ts = Td / 2;                   % Ts = 3.335 s
%%%%%%%%%%%%%%%%%%%%
% Identificação dos Parâmetros a partir dos Sinais Medidos
um=ma.signals(2).values;         N=length(um);
y=ma.signals(1).values;ym=y(:);
tm=0:length(um)-1;tm=tm';

%transit=2000; % descarta transitorio de Tamb ao P.O.
%ui=um(transit:length(um));yi=ym(transit:length(ym));
%Ni=length(ui); tid=0:Ni-1;tid=tid';
%uid=ui-mean(ui); yid=yi-mean(yi);

% Capacitância térmica do processo.
Ct = 0.0002;

% (Ka+Kt+Kw) =14.1657
Ka = 1; 
Kw = 4;
Kt = 9.1657;

Kp2 =  1/(Kt*Ct*Tp1); % ajuste de ganho de T(s)/U(s)

Am = (Tz-Tp1)/(Tp2-Tp1);
Bm = 1 - Am;

% Controlador PI Contínuo 
KP = 33.2;    
KI = KP / Tp2;

