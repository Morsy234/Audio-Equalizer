function varargout = AudioEquilizer(varargin)
% AUDIOEQUILIZER MATLAB code for AudioEquilizer.fig
%      AUDIOEQUILIZER, by itself, creates a new AUDIOEQUILIZER or raises the existing
%      singleton*.
%
%      H = AUDIOEQUILIZER returns the handle to a new AUDIOEQUILIZER or the handle to
%      the existing singleton*.
%
%      AUDIOEQUILIZER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AUDIOEQUILIZER.M with the given input arguments.
%
%      AUDIOEQUILIZER('Property','Value',...) creates a new AUDIOEQUILIZER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AudioEquilizer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AudioEquilizer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AudioEquilizer

% Last Modified by GUIDE v2.5 21-May-2023 18:00:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AudioEquilizer_OpeningFcn, ...
                   'gui_OutputFcn',  @AudioEquilizer_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before AudioEquilizer is made visible.
function AudioEquilizer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AudioEquilizer (see VARARGIN)

% Choose default command line output for AudioEquilizer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes AudioEquilizer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = AudioEquilizer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in browseButton.
function browseButton_Callback(hObject, eventdata, handles)
% hObject    handle to browseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename pathname]=uigetfile({'*.wav'}, 'File Selector'); 
handles.fullpathname = strcat(pathname, filename);   
set(handles.fileNameLabel, 'String', handles.fullpathname)  
guidata(hObject, handles)                             


function FIR(hObject, handles)

% First get the gain of each range and convert from db to its magnitude
handles.g1=power(10,get(handles.slider1,'value')/20);
set(handles.textg1, 'String',handles.g1);% displays the specified value of the slider as integers in the box
handles.g2=power(10,get(handles.slider2,'value')/20);
set(handles.textg2, 'String',handles.g2);  
handles.g3=power(10,get(handles.slider3,'value')/20);
set(handles.textg3, 'String',handles.g3);
handles.g4=power(10,get(handles.slider4,'value')/20);
set(handles.textg4, 'String',handles.g4);
handles.g5=power(10,get(handles.slider5,'value')/20);
set(handles.textg5, 'String',handles.g5); 
handles.g6=power(10,get(handles.slider6,'value')/20);
set(handles.textg6, 'String',handles.g6);
handles.g7=power(10,get(handles.slider7,'value')/20);
set(handles.textg7, 'String',handles.g7);
handles.g8=power(10,get(handles.slider8,'value')/20);
set(handles.textg8, 'String',handles.g8);
handles.g9=power(10,get(handles.slider9,'value')/20);
set(handles.textg9, 'String',handles.g9);

global f1 f2 f3 f4 f5 f6 f7 f8 f9 ftotal;
global player

%read the input wave
[handles.y,handles.Fs] = audioread(handles.fullpathname);
set(handles.CurrentFsLabel, 'String', num2str(handles.Fs))

%Nyquist frequency
Fm=handles.Fs/2;
%order is 100
order=100;



%-------->Apply lowPass Filter to 1st range(0-170 HZ)
Fc_low=170; 
%lowpass of order 100
b1=fir1(order,Fc_low/Fm,'low');
%Multibly the filter with the gain
f1=handles.g1*filter(b1,1,handles.y);
%get the freq responce
Fresponce1=freqz(b1,1);                                  
figure(1); 
%magnitude of frequency responce
subplot(2,4,1);
plot(abs(Fresponce1));                      
title('Magnitude of frequency responce');
subplot(2,4,2);
plot(angle(Fresponce1));                    
title('phase of frequency responce');
%get the transferfunction
Tfun1=tf(b1,1);
%zeros and poles
subplot(2, 4, 3);
pzmap(b1,1);
title('Zeros & Poles of H1(Z) (0 - 170)');
%impulse responce
subplot(2, 4, 4);
impz(b1,1);
title('Impulse response h1(n)');
%step responce
subplot(2, 4, 5);
stepz(b1,1);
title('Step response S1(n)');


%convert in freq. domain
f1_fft=fftshift(fft(f1));
%output signal in time domain
subplot(2, 4, 6);
plot(f1);
title('Time domain of filtered signal f1(n)');

subplot(2, 4, 7);
plot(f1_fft);
title('Frequency domain of filtered signal f1_fft(w)');
%-------------------------------------------------------------
%-------->Apply BandPass Filter to 2nd range(170 - 300 HZ) 
%bandpass of order 100
b2=fir1(order,[170 300]./Fm,'bandpass');
%Multibly the filter with the gain
f2=handles.g2*filter(b2,1,handles.y);
%get the freq responce
Fresponce2=freqz(b2,1);                                  
figure(2); 
%magnitude of frequency responce
subplot(2,4,1);
plot(abs(Fresponce2));                      
title('Magnitude of frequency responce');
subplot(2,4,2);
plot(angle(Fresponce2));                    
title('phase of frequency responce');
%get the transferfunction
Tfun2=tf(b2,1);
%zeros and poles
subplot(2, 4, 3);
pzmap(b2,1);
title('Zeros & Poles of H2(Z) (170 - 300)');
%impulse responce
subplot(2, 4, 4);
impz(b2,1);
title('Impulse response h2(n)');
%step responce
subplot(2, 4, 5);
stepz(b2,1);
title('Step response S2(n)')


%convert in freq. domain
f2_fft=fftshift(fft(f2));
%output signal in time domain
subplot(2, 4, 6);
plot(f2);
title('Time domain of filtered signal f2(n)');

subplot(2, 4, 7);
plot(f2_fft);
title('Frequency domain of filtered signal f2_fft(w)');
%-------------------------------------------------------------
%-------->Apply BandPass Filter to 3rd range(300 - 610 HZ) 
%bandpass of order 100
b3 =fir1(order,[300 610]./Fm,'bandpass');
%Multibly the filter with the gain
f3=handles.g3*filter(b3,1,handles.y);
%get the freq responce
Fresponce3=freqz(b3,1);                                  
figure(3); 
%magnitude of frequency responce
subplot(2,4,1);
plot(abs(Fresponce3));                      
title('Magnitude of frequency responce');
subplot(2,4,2);
plot(angle(Fresponce3));                    
title('phase of frequency responce');
%get the transferfunction
Tfun3=tf(b3,1);
%zeros and poles
subplot(2, 4, 3);
pzmap(b3,1);
title('Zeros & Poles of H3(Z) (300 - 610)');
%impulse responce
subplot(2, 4, 4);
impz(b3,1);
title('Impulse response h3(n)');
%step responce
subplot(2, 4, 5);
stepz(b3,1);
title('Step response S3(n)')


%convert in freq. domain
f3_fft=fftshift(fft(f3));
%output signal in time domain
subplot(2, 4, 6);
plot(f3);
title('Time domain of filtered signal f3(n)');

subplot(2, 4, 7);
plot(f3_fft);
title('Frequency domain of filtered signal f3_fft(w)');

%-------------------------------------------------------------
%-------->Apply BandPass Filter to 4th range(610 - 1005 HZ) 
%bandpass of order 100
b4 = fir1(order,[610 1005]./Fm,'bandpass');
%Multiply the filter with the gain
f4 = handles.g4 * filter(b4,1,handles.y);
%Get the frequency response
Fresponse4 = freqz(b4,1);                                  
figure(4); 
%Magnitude of frequency response
subplot(2,4,1);
plot(abs(Fresponse4));                      
title('Magnitude of frequency response');
subplot(2,4,2);
plot(angle(Fresponse4));                    
title('Phase of frequency response');
%Get the transfer function
Tfun4 = tf(b4,1);
%Zeros and poles
subplot(2, 4, 3);
pzmap(b4,1);
title('Zeros & Poles of H4(Z) (610 - 1005)');
%Impulse response
subplot(2, 4, 4);
impz(b4,1);
title('Impulse response h4(n)');
%Step response
subplot(2, 4, 5);
stepz(b4,1);
title('Step response S4(n)');

%Convert to frequency domain
f4_fft = fftshift(fft(f4));
%Output signal in time domain
subplot(2, 4, 6);
plot(f4);
title('Time domain of filtered signal f4(n)');

subplot(2, 4, 7);
plot(f4_fft);
title('Frequency domain of filtered signal f4_fft(w)');
%-------------------------------------------------------------
%-------->Apply BandPass Filter to 5th range(1005 -3 kHZ) 
%bandpass of order 100
b5 = fir1(order,[1005 3000]./Fm,'bandpass');
%Multiply the filter with the gain
f5 = handles.g5 * filter(b5,1,handles.y);
%Get the frequency response
Fresponse5 = freqz(b5,1);                                  
figure(5); 
%Magnitude of frequency response
subplot(2,4,1);
plot(abs(Fresponse5));                      
title('Magnitude of frequency response');
subplot(2,4,2);
plot(angle(Fresponse5));                    
title('Phase of frequency response');
%Get the transfer function
Tfun5 = tf(b5,1);
%Zeros and poles
subplot(2, 4, 3);
pzmap(b5,1);
title('Zeros & Poles of H5(Z) (300 - 610)');
%Impulse response
subplot(2, 4, 4);
impz(b5,1);
title('Impulse response h5(n)');
%Step response
subplot(2, 4, 5);
stepz(b5,1);
title('Step response S5(n)');

%Convert to frequency domain
f5_fft = fftshift(fft(f5));
%Output signal in time domain
subplot(2, 4, 6);
plot(f5);
title('Time domain of filtered signal f5(n)');

subplot(2, 4, 7);
plot(f5_fft);
title('Frequency domain of filtered signal f5_fft(w)');
%-------------------------------------------------------------
%-------->Apply BandPass Filter to 6th range(3 - 6 kHz) 
%bandpass of order 100
b6 = fir1(order,[3000 6000]./Fm,'bandpass');
%Multiply the filter with the gain
f6 = handles.g6 * filter(b6,1,handles.y);
%Get the frequency response
Fresponse6 = freqz(b6,1);                                  
figure(6); 
%Magnitude of frequency response
subplot(2,4,1);
plot(abs(Fresponse6));                      
title('Magnitude of frequency response');
subplot(2,4,2);
plot(angle(Fresponse6));                    
title('Phase of frequency response');
%Get the transfer function
Tfun6 = tf(b6,1);
%Zeros and poles
subplot(2, 4, 3);
pzmap(b6,1);
title('Zeros & Poles of H6(Z) (3 -6 kHz)');
%Impulse response
subplot(2, 4, 4);
impz(b6,1);
title('Impulse response h6(n)');
%Step response
subplot(2, 4, 5);
stepz(b6,1);
title('Step response S6(n)');

%Convert to frequency domain
f6_fft = fftshift(fft(f6));
%Output signal in time domain
subplot(2, 4, 6);
plot(f6);
title('Time domain of filtered signal f6(n)');

subplot(2, 4, 7);
plot(f6_fft);
title('Frequency domain of filtered signal f6_fft(w)');
%-------------------------------------------------------------
%-------->Apply BandPass Filter to 7th range(6 -12 kHz) 
%bandpass of order 100
b7 = fir1(order,[6000 12000]./Fm,'bandpass');
%Multiply the filter with the gain
f7 = handles.g7 * filter(b7,1,handles.y);
%Get the frequency response
Fresponse7 = freqz(b7,1);                                  
figure(7); 
%Magnitude of frequency response
subplot(2,4,1);
plot(abs(Fresponse7));                      
title('Magnitude of frequency response');
subplot(2,4,2);
plot(angle(Fresponse7));                    
title('Phase of frequency response');
%Get the transfer function
Tfun7 = tf(b7,1);
%Zeros and poles
subplot(2, 4, 3);
pzmap(b7,1);
title('Zeros & Poles of H7(Z) (6 - 12 kHz)');
%Impulse response
subplot(2, 4, 4);
impz(b7,1);
title('Impulse response h7(n)');
%Step response
subplot(2, 4, 5);
stepz(b7,1);
title('Step response S7(n)');

%Convert to frequency domain
f7_fft = fftshift(fft(f7));
%Output signal in time domain
subplot(2, 4, 6);
plot(f7);
title('Time domain of filtered signal f7(n)');

subplot(2, 4, 7);
plot(f7_fft);
title('Frequency domain of filtered signal f7_fft(w)');
%-------------------------------------------------------------
%-------->Apply BandPass Filter to 8th range(12 - 14 kHz) 
%bandpass of order 4
b8 = fir1(order,[12000 14000]./Fm,'bandpass');
%Multiply the filter with the gain
f8 = handles.g8 * filter(b8,1,handles.y);
%Get the frequency response
Fresponse8 = freqz(b8,1);                                  
figure(8); 
%Magnitude of frequency response
subplot(2,4,1);
plot(abs(Fresponse8));                      
title('Magnitude of frequency response');
subplot(2,4,2);
plot(angle(Fresponse8));                    
title('Phase of frequency response');
%Get the transfer function
Tfun8 = tf(b8,1);
%Zeros and poles
subplot(2, 4, 3);
pzmap(b8,1);
title('Zeros & Poles of H8(Z) (12 - 14 kHz)');
%Impulse response
subplot(2, 4, 4);
impz(b8,1);
title('Impulse response h8(n)');
%Step response
subplot(2, 4, 5);
stepz(b8,1);
title('Step response S8(n)');

%Convert to frequency domain
f8_fft = fftshift(fft(f8));
%Output signal in time domain
subplot(2, 4, 6);
plot(f8);
title('Time domain of filtered signal f8(n)');

subplot(2, 4, 7);
plot(f8_fft);
title('Frequency domain of filtered signal f8_fft(w)');
%-------------------------------------------------------------
%-------->Apply BandPass Filter to 9th range(14 - 20 kHz) 
%bandpass of order 100
b9 = fir1(order,[14000 20000]./Fm,'bandpass');
%Multiply the filter with the gain
f9 = handles.g9 * filter(b9,1,handles.y);
%Get the frequency response
Fresponse9 = freqz(b9,1);                                  
figure(9); 
%Magnitude of frequency response
subplot(2,4,1);
plot(abs(Fresponse9));                      
title('Magnitude of frequency response');
subplot(2,4,2);
plot(angle(Fresponse9));                    
title('Phase of frequency response');
%Get the transfer function
Tfun9 = tf(b9,1);
%Zeros and poles
subplot(2, 4, 3);
pzmap(b9,1);
title('Zeros & Poles of H9(Z) (14 - 20 kHz)');
%Impulse response
subplot(2, 4, 4);
impz(b9,1);
title('Impulse response h9(n)');
%Step response
subplot(2, 4, 5);
stepz(b9,1);
title('Step response S9(n)');

%Convert to frequency domain
f9_fft = fftshift(fft(f9));
%Output signal in time domain
subplot(2, 4, 6);
plot(f9);
title('Time domain of filtered signal f9(n)');

subplot(2, 4, 7);
plot(f9_fft);
title('Frequency domain of filtered signal f9_fft(w)');
%-------------------------------------------------------------
%------------------->collecting the composite signal
handles.ftotal=f1+f2+f3+f4+f5+f6+f7+f8+f9;  %get the output signal after passing through all the filters
handles.ftotal_fft=abs(fftshift(fft(handles.ftotal)));   %output signal in frequency domain
sound(handles.ftotal, handles.Fs); %play the output signal
figure(10);
subplot(2,2,1);
plot(handles.y);
title('original signal in time')  
subplot(2,2,3);
plot(fftshift(fft(handles.y)));
title('original signal in frequency')
subplot(2,2,2);
plot(handles.ftotal);
title('composite signal in time')
subplot(2,2,4);
plot(handles.ftotal_fft);
title('composite signal in freq') 
%--------------------------------------------------------------
%------------------------->Plot original and enhanced signal in our GUI
%original signal
axes(handles.axes1);
plot(handles.y);

%filtered signal
axes(handles.axes2);
plot(handles.ftotal);
 guidata(hObject,handles)

 
 
function IIR(hObject, handles)

% First get the gain of each range and convert from db to its magnitude
handles.g1=power(10,get(handles.slider1,'value')/20);
set(handles.textg1, 'String',handles.g1);% displays the specified value of the slider as integers in the box
handles.g2=power(10,get(handles.slider2,'value')/20);
set(handles.textg2, 'String',handles.g2);  
handles.g3=power(10,get(handles.slider3,'value')/20);
set(handles.textg3, 'String',handles.g3);
handles.g4=power(10,get(handles.slider4,'value')/20);
set(handles.textg4, 'String',handles.g4);
handles.g5=power(10,get(handles.slider5,'value')/20);
set(handles.textg5, 'String',handles.g5); 
handles.g6=power(10,get(handles.slider6,'value')/20);
set(handles.textg6, 'String',handles.g6);
handles.g7=power(10,get(handles.slider7,'value')/20);
set(handles.textg7, 'String',handles.g7);
handles.g8=power(10,get(handles.slider8,'value')/20);
set(handles.textg8, 'String',handles.g8);
handles.g9=power(10,get(handles.slider9,'value')/20);
set(handles.textg9, 'String',handles.g9);

global f1 f2 f3 f4 f5 f6 f7 f8 f9 ftotal;
global player

%read the input wave
[handles.y,handles.Fs] = audioread(handles.fullpathname);
set(handles.CurrentFsLabel, 'String', num2str(handles.Fs))

%Nyquist frequency
Fm=handles.Fs/2;
%order is 4
order=4;




%-------->Apply lowPass Filter to 1st range(0-170 HZ)
Fc_low=170; 
%lowpass of order 4
[b1,a1]=butter(order,Fc_low/Fm,'low');
%Multibly the filter with the gain
f1=handles.g1*filter(b1,a1,handles.y);
%get the freq responce
Fresponce1=freqz(b1,a1);                                  
figure(1); 
%magnitude of frequency responce
subplot(2,4,1);
plot(abs(Fresponce1));                      
title('Magnitude of frequency responce');
subplot(2,4,2);
plot(angle(Fresponce1));                    
title('phase of frequency responce');
%get the transferfunction
Tfun1=tf(b1,a1);
%zeros and poles
subplot(2, 4, 3);
pzmap(b1,a1);
title('Zeros & Poles of H1(Z) (0 - 170)');
%impulse responce
subplot(2, 4, 4);
impz(b1,a1);
title('Impulse response h1(n)');
%step responce
subplot(2, 4, 5);
stepz(b1,a1);
title('Step response S1(n)');


%convert in freq. domain
f1_fft=fftshift(fft(f1));
%output signal in time domain
subplot(2, 4, 6);
plot(f1);
title('Time domain of filtered signal f1(n)');

subplot(2, 4, 7);
plot(f1_fft);
title('Frequency domain of filtered signal f1_fft(w)');

%-------------------------------------------------------------
%-------->Apply BandPass Filter to 2nd range(170 - 300 HZ) 
%bandpass of order 4
[b2,a2]=butter(order,[170 300]./Fm,'bandpass');
%Multibly the filter with the gain
f2=handles.g2*filter(b2,a2,handles.y);
%get the freq responce
Fresponce2=freqz(b2,a2);                                  
figure(2); 
%magnitude of frequency responce
subplot(2,4,1);
plot(abs(Fresponce2));                      
title('Magnitude of frequency responce');
subplot(2,4,2);
plot(angle(Fresponce2));                    
title('phase of frequency responce');
%get the transferfunction
Tfun2=tf(b2,a2);
%zeros and poles
subplot(2, 4, 3);
pzmap(b2,a2);
title('Zeros & Poles of H2(Z) (170 - 300)');
%impulse responce
subplot(2, 4, 4);
impz(b2,a2);
title('Impulse response h2(n)');
%step responce
subplot(2, 4, 5);
stepz(b2,a2);
title('Step response S2(n)')


%convert in freq. domain
f2_fft=fftshift(fft(f2));
%output signal in time domain
subplot(2, 4, 6);
plot(f2);
title('Time domain of filtered signal f2(n)');

subplot(2, 4, 7);
plot(f2_fft);
title('Frequency domain of filtered signal f2_fft(w)');
%--------------------------------------------------------------
%-------->Apply BandPass Filter to 3rd range(300 - 610 HZ) 
%bandpass of order 4
[b3,a3]=butter(order,[300 610]./Fm,'bandpass');
%Multibly the filter with the gain
f3=handles.g3*filter(b3,a3,handles.y);
%get the freq responce
Fresponce3=freqz(b3,a3);                                  
figure(3); 
%magnitude of frequency responce
subplot(2,4,1);
plot(abs(Fresponce3));                      
title('Magnitude of frequency responce');
subplot(2,4,2);
plot(angle(Fresponce3));                    
title('phase of frequency responce');
%get the transferfunction
Tfun3=tf(b3,a3);
%zeros and poles
subplot(2, 4, 3);
pzmap(b3,a3);
title('Zeros & Poles of H3(Z) (300 - 610)');
%impulse responce
subplot(2, 4, 4);
impz(b3,a3);
title('Impulse response h3(n)');
%step responce
subplot(2, 4, 5);
stepz(b3,a3);
title('Step response S3(n)')


%convert in freq. domain
f3_fft=fftshift(fft(f3));
%output signal in time domain
subplot(2, 4, 6);
plot(f3);
title('Time domain of filtered signal f3(n)');

subplot(2, 4, 7);
plot(f3_fft);
title('Frequency domain of filtered signal f3_fft(w)');

%-------------------------------------------------------------
%-------->Apply BandPass Filter to 4th range(610 - 1005 HZ) 
%bandpass of order 4
[b4,a4] = butter(order,[610 1005]./Fm,'bandpass');
%Multiply the filter with the gain
f4 = handles.g4 * filter(b4,a4,handles.y);
%Get the frequency response
Fresponse4 = freqz(b4,a4);                                  
figure(4); 
%Magnitude of frequency response
subplot(2,4,1);
plot(abs(Fresponse4));                      
title('Magnitude of frequency response');
subplot(2,4,2);
plot(angle(Fresponse4));                    
title('Phase of frequency response');
%Get the transfer function
Tfun4 = tf(b4,a4);
%Zeros and poles
subplot(2, 4, 3);
pzmap(b4,a4);
title('Zeros & Poles of H4(Z) (610 - 1005)');
%Impulse response
subplot(2, 4, 4);
impz(b4,a4);
title('Impulse response h4(n)');
%Step response
subplot(2, 4, 5);
stepz(b4,a4);
title('Step response S4(n)');

%Convert to frequency domain
f4_fft = fftshift(fft(f4));
%Output signal in time domain
subplot(2, 4, 6);
plot(f4);
title('Time domain of filtered signal f4(n)');

subplot(2, 4, 7);
plot(f4_fft);
title('Frequency domain of filtered signal f4_fft(w)');
%-------------------------------------------------------------
%-------->Apply BandPass Filter to 5th range(1005 -3 kHZ) 
%bandpass of order 4
[b5,a5] = butter(order,[1005 3000]./Fm,'bandpass');
%Multiply the filter with the gain
f5 = handles.g5 * filter(b5,a5,handles.y);
%Get the frequency response
Fresponse5 = freqz(b5,a5);                                  
figure(5); 
%Magnitude of frequency response
subplot(2,4,1);
plot(abs(Fresponse5));                      
title('Magnitude of frequency response');
subplot(2,4,2);
plot(angle(Fresponse5));                    
title('Phase of frequency response');
%Get the transfer function
Tfun5 = tf(b5,a5);
%Zeros and poles
subplot(2, 4, 3);
pzmap(b5,a5);
title('Zeros & Poles of H5(Z) (300 - 610)');
%Impulse response
subplot(2, 4, 4);
impz(b5,a5);
title('Impulse response h5(n)');
%Step response
subplot(2, 4, 5);
stepz(b5,a5);
title('Step response S5(n)');

%Convert to frequency domain
f5_fft = fftshift(fft(f5));
%Output signal in time domain
subplot(2, 4, 6);
plot(f5);
title('Time domain of filtered signal f5(n)');

subplot(2, 4, 7);
plot(f5_fft);
title('Frequency domain of filtered signal f5_fft(w)');
%-------------------------------------------------------------
%-------->Apply BandPass Filter to 6th range(3 - 6 kHz) 
%bandpass of order 4
[b6,a6] = butter(order,[3000 6000]./Fm,'bandpass');
%Multiply the filter with the gain
f6 = handles.g6 * filter(b6,a6,handles.y);
%Get the frequency response
Fresponse6 = freqz(b6,a6);                                  
figure(6); 
%Magnitude of frequency response
subplot(2,4,1);
plot(abs(Fresponse6));                      
title('Magnitude of frequency response');
subplot(2,4,2);
plot(angle(Fresponse6));                    
title('Phase of frequency response');
%Get the transfer function
Tfun6 = tf(b6,a6);
%Zeros and poles
subplot(2, 4, 3);
pzmap(b6,a6);
title('Zeros & Poles of H6(Z) (3 -6 kHz)');
%Impulse response
subplot(2, 4, 4);
impz(b6,a6);
title('Impulse response h6(n)');
%Step response
subplot(2, 4, 5);
stepz(b6,a6);
title('Step response S6(n)');

%Convert to frequency domain
f6_fft = fftshift(fft(f6));
%Output signal in time domain
subplot(2, 4, 6);
plot(f6);
title('Time domain of filtered signal f6(n)');

subplot(2, 4, 7);
plot(f6_fft);
title('Frequency domain of filtered signal f6_fft(w)');
%-------------------------------------------------------------
%-------->Apply BandPass Filter to 7th range(6 -12 kHz) 
%bandpass of order 4
[b7,a7] = butter(order,[6000 12000]./Fm,'bandpass');
%Multiply the filter with the gain
f7 = handles.g7 * filter(b7,a7,handles.y);
%Get the frequency response
Fresponse7 = freqz(b7,a7);                                  
figure(7); 
%Magnitude of frequency response
subplot(2,4,1);
plot(abs(Fresponse7));                      
title('Magnitude of frequency response');
subplot(2,4,2);
plot(angle(Fresponse7));                    
title('Phase of frequency response');
%Get the transfer function
Tfun7 = tf(b7,a7);
%Zeros and poles
subplot(2, 4, 3);
pzmap(b7,a7);
title('Zeros & Poles of H7(Z) (6 - 12 kHz)');
%Impulse response
subplot(2, 4, 4);
impz(b7,a7);
title('Impulse response h7(n)');
%Step response
subplot(2, 4, 5);
stepz(b7,a7);
title('Step response S7(n)');

%Convert to frequency domain
f7_fft = fftshift(fft(f7));
%Output signal in time domain
subplot(2, 4, 6);
plot(f7);
title('Time domain of filtered signal f7(n)');

subplot(2, 4, 7);
plot(f7_fft);
title('Frequency domain of filtered signal f7_fft(w)');
%-------------------------------------------------------------
%-------->Apply BandPass Filter to 8th range(12 - 14 kHz) 
%bandpass of order 4
[b8,a8] = butter(order,[12000 14000]./Fm,'bandpass');
%Multiply the filter with the gain
f8 = handles.g8 * filter(b8,a8,handles.y);
%Get the frequency response
Fresponse8 = freqz(b8,a8);                                  
figure(8); 
%Magnitude of frequency response
subplot(2,4,1);
plot(abs(Fresponse8));                      
title('Magnitude of frequency response');
subplot(2,4,2);
plot(angle(Fresponse8));                    
title('Phase of frequency response');
%Get the transfer function
Tfun8 = tf(b8,a8);
%Zeros and poles
subplot(2, 4, 3);
pzmap(b8,a8);
title('Zeros & Poles of H8(Z) (12 - 14 kHz)');
%Impulse response
subplot(2, 4, 4);
impz(b8,a8);
title('Impulse response h8(n)');
%Step response
subplot(2, 4, 5);
stepz(b8,a8);
title('Step response S8(n)');

%Convert to frequency domain
f8_fft = fftshift(fft(f8));
%Output signal in time domain
subplot(2, 4, 6);
plot(f8);
title('Time domain of filtered signal f8(n)');

subplot(2, 4, 7);
plot(f8_fft);
title('Frequency domain of filtered signal f8_fft(w)');
%-------------------------------------------------------------
%-------->Apply BandPass Filter to 9th range(14 - 20 kHz) 
%bandpass of order 4
[b9,a9] = butter(order,[14000 20000]./Fm,'bandpass');
%Multiply the filter with the gain
f9 = handles.g9 * filter(b9,a9,handles.y);
%Get the frequency response
Fresponse9 = freqz(b9,a9);                                  
figure(9); 
%Magnitude of frequency response
subplot(2,4,1);
plot(abs(Fresponse9));                      
title('Magnitude of frequency response');
subplot(2,4,2);
plot(angle(Fresponse9));                    
title('Phase of frequency response');
%Get the transfer function
Tfun9 = tf(b9,a9);
%Zeros and poles
subplot(2, 4, 3);
pzmap(b9,a9);
title('Zeros & Poles of H9(Z) (14 - 20 kHz)');
%Impulse response
subplot(2, 4, 4);
impz(b4,a4);title('Impulse response h9(n)');
%Step response
subplot(2, 4, 5);
stepz(b9,a9);
title('Step response S9(n)');

%Convert to frequency domain
f9_fft = fftshift(fft(f9));
%Output signal in time domain
subplot(2, 4, 6);
plot(f9);
title('Time domain of filtered signal f9(n)');

subplot(2, 4, 7);
plot(f9_fft);
title('Frequency domain of filtered signal f9_fft(w)');
%-------------------------------------------------------------
%------------------->collecting the composite signal
handles.ftotal=f1+f2+f3+f4+f5+f6+f7+f8+f9;  %get the output signal after passing through all the filters
handles.YT=abs(fftshift(fft(handles.ftotal)));   %output signal in frequency domain
sound(handles.ftotal, handles.Fs); %play the output signal
figure(10);
subplot(2,2,1);
plot(handles.y);
title('original signal in time')  
subplot(2,2,3);
plot(fftshift(fft(handles.y)));
title('original signal in frequency')
subplot(2,2,2);
plot(handles.ftotal);
title('composite signal in time')
subplot(2,2,4);
plot(handles.YT);
title('composite signal in freq') 

%------------------------->Plot original and enhanced signal in our GUI
%original signal
axes(handles.axes1);
plot(handles.y);

%filtered signal
axes(handles.axes2);
plot(handles.ftotal);

 guidata(hObject,handles)


% --- Executes on button press in Playbutton.
function Playbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Playbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 if (get(handles.FIRbutton,'value')==1)
      set(handles.FilterTypeLabel, 'String', 'using FIR')
      FIR(hObject, handles)
 elseif (get(handles.IIRbutton,'value')==1)
      set(handles.FilterTypeLabel, 'String', 'using IIR')
      IIR(hObject, handles)
 end
     

   
    
   

% --- Executes on button press in Stopbutton.
function Stopbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Stopbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%global player;
%pause(player);
clear sound;


% --- Executes on button press in FIRbutton.
function FIRbutton_Callback(hObject, eventdata, handles)
% hObject    handle to FIRbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of FIRbutton


%check that the IIR is disabled while using FIR 
if get(handles.IIRbutton,'value')==1
    set(handles.IIRbutton,'value',0)
end



% --- Executes on button press in IIRbutton.
function IIRbutton_Callback(hObject, eventdata, handles)
% hObject    handle to IIRbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of IIRbutton

%check that the FIR is disabled while using IIR 
if get(handles.FIRbutton,'value')==1
    set(handles.FIRbutton,'value',0)
end

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider4_Callback(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider5_Callback(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider6_Callback(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider7_Callback(hObject, eventdata, handles)
% hObject    handle to slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider8_Callback(hObject, eventdata, handles)
% hObject    handle to slider8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider9_Callback(hObject, eventdata, handles)
% hObject    handle to slider9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function editFsText_Callback(hObject, eventdata, handles)
% hObject    handle to editFsText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFsText as text
%        str2double(get(hObject,'String')) returns contents of editFsText as a double


 guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function editFsText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFsText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DoubleFsbutton.
function DoubleFsbutton_Callback(hObject, eventdata, handles)
% hObject    handle to DoubleFsbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global fs_new; 
global f1 f2 f3 f4 f5 f6 f7 f8 f9 ;
%taking the o/p freq from user
fs_new=str2double(char(get(handles.editFsText, 'String'))); 
fs_new=fs_new*2;
set(handles.CurrentFsLabel, 'String', num2str(fs_new))


%the output composite signal
handles.ftotal=f1+f2+f3+f4+f5+f6+f7+f8+f9;   
audiowrite('composite_double_output.wav',handles.ftotal,fs_new); %save the composite signal as .wav file
[Sound,fss_new]=audioread('composite_double_output.wav');     

%signal in freq domain
fft_Sound=abs(fftshift(fft(Sound)));   
sound(Sound,fss_new); 
%play(player)                              
figure;
subplot(2,1,1);
plot(Sound);
title('signal if o/p sample rate is the double in time domain');
subplot(2,1,2);
plot(fft_Sound);
title('signal if o/p sample rate is the double in frequency domain');
%------------------------->Plot original and enhanced signal in our GUI
%original signal
axes(handles.axes1);
plot(handles.y);

%filtered signal
axes(handles.axes2);
plot(handles.ftotal);

% --- Executes on button press in HalfFSbutton.
function HalfFSbutton_Callback(hObject, eventdata, handles)
% hObject    handle to HalfFSbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global fs_new; 
global f1 f2 f3 f4 f5 f6 f7 f8 f9 ;
%taking the o/p freq from user
fs_new=str2double(char(get(handles.editFsText, 'String'))); 
fs_new=fs_new/2;
set(handles.CurrentFsLabel, 'String', num2str(fs_new))


%the output composite signal
handles.ftotal=f1+f2+f3+f4+f5+f6+f7+f8+f9;   
audiowrite('composite_half_output.wav',handles.ftotal,fs_new); %save the composite signal as .wav file
[Sound,fss_new]=audioread('composite_half_output.wav');     

%signal in freq domain
fft_Sound=abs(fftshift(fft(Sound)));   
sound(Sound,fss_new); 
%play(player)                              
figure;
subplot(2,1,1);
plot(Sound);
title('signal if o/p sample rate is the half in time domain');
subplot(2,1,2);
plot(fft_Sound);
title('signal if o/p sample rate is the half in frequency domain');
%------------------------->Plot original and enhanced signal in our GUI
%original signal
axes(handles.axes1);
plot(handles.y);

%filtered signal
axes(handles.axes2);
plot(handles.ftotal);


% --- Executes on button press in NewFsbutton.
function NewFsbutton_Callback(hObject, eventdata, handles)
% hObject    handle to NewFsbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global fs_new; 
global f1 f2 f3 f4 f5 f6 f7 f8 f9 ;
%taking the o/p freq from user
fs_new=str2double(char(get(handles.editFsText, 'String')));
set(handles.CurrentFsLabel, 'String', num2str(fs_new))

%the output composite signal
handles.ftotal=f1+f2+f3+f4+f5+f6+f7+f8+f9;   
audiowrite('composite_new_output.wav',handles.ftotal,fs_new); %save the composite signal as .wav file
[Sound,fss_new]=audioread('composite_new_output.wav');     

%signal in freq domain
fft_Sound=abs(fftshift(fft(Sound)));   
sound(Sound,fss_new); 
%play(player)                              
figure;
subplot(2,1,1);
plot(Sound);
title('signal if o/p sample rate is updated in time domain');
subplot(2,1,2);
plot(fft_Sound);
title('signal if o/p sample rate is updated in frequency domain');
%------------------------->Plot original and enhanced signal in our GUI
%original signal
axes(handles.axes1);
plot(handles.y);

%filtered signal
axes(handles.axes2);
plot(handles.ftotal);


% --- Executes on button press in savebutton.
function savebutton_Callback(hObject, eventdata, handles)
% hObject    handle to savebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
audiowrite('Filtered_output.wav',handles.ftotal,handles.Fs);
