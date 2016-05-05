function varargout = craigslist_GUI(varargin)
% CRAIGSLIST_GUI MATLAB code for craigslist_GUI.fig
%      CRAIGSLIST_GUI, by itself, creates a new CRAIGSLIST_GUI or raises the existing
%      singleton*.
%
%      H = CRAIGSLIST_GUI returns the handle to a new CRAIGSLIST_GUI or the handle to
%      the existing singleton*.
%
%      CRAIGSLIST_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CRAIGSLIST_GUI.M with the given input arguments.
%
%      CRAIGSLIST_GUI('Property','Value',...) creates a new CRAIGSLIST_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before craigslist_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to craigslist_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help craigslist_GUI

% Last Modified by GUIDE v2.5 17-Apr-2016 17:52:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @craigslist_GUI_OpeningFcn, ...
    'gui_OutputFcn',  @craigslist_GUI_OutputFcn, ...
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


% --- Executes just before craigslist_GUI is made visible.
function craigslist_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to craigslist_GUI (see VARARGIN)


%Scrape state and city list from craigslist
url = 'http://www.craigslist.org/about/sites';
html = urlread(url);
save('html','html');

%isolate to US
us_start = strfind(html,'<h1>');
html = html(us_start(1):us_start(2));

%search for states
state_start = strfind(html,'<h4>');
state_end = strfind(html,'</h4>');

for i=1:length(state_start)
    state_name{i} = html(state_start(i)+4:state_end(i)-1);
    MKT(i).name = state_name{i};
end

%search for cities
for i=1:length(MKT)
    
    if i==length(MKT)
        sub_html = html(state_start(i):end);
    else
        sub_html = html(state_start(i):state_start(i+1));
    end
    
    city_start = strfind(sub_html,'<a href="');
    city_end = strfind(sub_html, '</a>');
    
    for j=1:length(city_start)
        sub_sub_html = sub_html(city_start(j):city_end(j));
        brace = strfind(sub_sub_html,'>');
        MKT(i).city_name{j} = sub_sub_html(brace+1:end-1);
        MKT(i).city_url{j} = sub_sub_html(12:brace-2);
    end
end

handles.MKT = MKT;
states  = {MKT(:).name};
set(handles.states_A,'string',states);
set(handles.states_B,'string',states);

%create bedroom and bathroom fields
handles.bedroom = {'all bedrooms','1+ bedrooms','2+ bedrooms','3+ bedrooms',...
    '4+ bedrooms','5+ bedrooms'};
handles.bathroom = {'all bathrooms','1+ bathrooms','2+ bathrooms','3+ bathrooms',...
    '4+ bathrooms','5+ bathrooms'};

set(handles.bedrooms_A,'string',handles.bedroom);
set(handles.bedrooms_B,'string',handles.bedroom);

set(handles.bathrooms_A,'string',handles.bathroom);
set(handles.bathrooms_B,'string',handles.bathroom);

% Choose default command line output for craigslist_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes craigslist_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = craigslist_GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in states_A.
function states_A_Callback(hObject, eventdata, handles)
% hObject    handle to states_A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = get(hObject,'String');
curr_state = contents{get(hObject,'Value')};
selected = get(hObject,'Value');

num_cities = length(handles.MKT(selected).city_name);

set(handles.cities_A,'Value',1)
set(handles.cities_A,'string',handles.MKT(selected).city_name);

cities_A_Callback(handles.cities_A, [], handles)

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function states_A_CreateFcn(hObject, eventdata, handles)
% hObject    handle to states_A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in cities_A.
function cities_A_Callback(hObject, eventdata, handles)
% hObject    handle to cities_A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

state  = get(handles.states_A,'Value');
city = get(handles.cities_A,'Value');

handles.city_url_A = handles.MKT(state).city_url{city};

%scrape walkability score
load state_abbr
city_name = handles.MKT(state).city_name{city};
city_name = city_name(~isspace(city_name));
url = ['https://www.walkscore.com/' state_abbr{state} '/' city_name];

try
    score = urlfilter(url,'.svg',1,'backward');
catch err
    score = 'No score avaliable';
end

handles.score_A = score;

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function cities_A_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cities_A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in states_B.
function states_B_Callback(hObject, eventdata, handles)
% hObject    handle to states_B (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = get(hObject,'String');
curr_state = contents{get(hObject,'Value')};
selected = get(hObject,'Value');

num_cities = length(handles.MKT(selected).city_name);

set(handles.cities_B,'Value',1)
set(handles.cities_B,'string',handles.MKT(selected).city_name);

cities_B_Callback(handles.cities_B, [], handles)

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function states_B_CreateFcn(hObject, eventdata, handles)
% hObject    handle to states_B (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in cities_B.
function cities_B_Callback(hObject, eventdata, handles)
% hObject    handle to cities_B (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

state  = get(handles.states_B,'Value');
city = get(handles.cities_B,'Value');

handles.city_url_B = handles.MKT(state).city_url{city};

%scrape walkability score
load state_abbr
city_name = handles.MKT(state).city_name{city};
city_name = city_name(~isspace(city_name));
url = ['https://www.walkscore.com/' state_abbr{state} '/' city_name];

try
    score = urlfilter(url,'.svg',1,'backward');
catch err
    score = 'No score avaliable';
end

handles.score_B = score;

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function cities_B_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cities_B (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in bedrooms_A.
function bedrooms_A_Callback(hObject, eventdata, handles)
% hObject    handle to bedrooms_A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = get(hObject,'String');
selected = get(hObject,'Value');

if selected == 1
    bed_url_A = '';
else
    bed_url_A = ['bedrooms=' mat2str(selected-1)];
end

handles.bed_url_A = bed_url_A;

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function bedrooms_A_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bedrooms_A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in bathrooms_A.
function bathrooms_A_Callback(hObject, eventdata, handles)
% hObject    handle to bathrooms_A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = get(hObject,'String');
selected = get(hObject,'Value');

if selected == 1
    bath_url_A = '';
else
    bath_url_A = ['bathrooms=' mat2str(selected-1)];
end

handles.bath_url_A = bath_url_A;

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function bathrooms_A_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bathrooms_A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in bathrooms_B.
function bathrooms_B_Callback(hObject, eventdata, handles)
% hObject    handle to bathrooms_B (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = get(hObject,'String');
selected = get(hObject,'Value');

if selected == 1
    bath_url_B = '';
else
    bath_url_B = ['bathrooms=' mat2str(selected-1)];
end

handles.bath_url_B = bath_url_B;

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function bathrooms_B_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bathrooms_B (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in bedrooms_B.
function bedrooms_B_Callback(hObject, eventdata, handles)
% hObject    handle to bedrooms_B (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = get(hObject,'String');
selected = get(hObject,'Value');

if selected == 1
    bed_url_B = '';
else
    bed_url_B = ['bedrooms=' mat2str(selected-1)];
end

handles.bed_url_B = bed_url_B;

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function bedrooms_B_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bedrooms_B (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in fetch.
function fetch_Callback(hObject, eventdata, handles)
% hObject    handle to fetch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

types = {'A','B'};
for i=1:length(types)
    
    % get end of url
    if isfield(handles, ['bed_url_' types{i}]) & isfield(handles, ['bath_url_' types{i}])
        tag = [eval(['handles.bed_url_' types{i}]) '&' eval(['handles.bath_url_' types{i}])];
    elseif isfield(handles, 'bed_url_A') & ~isfield(handles, 'bath_url_A')
        tag = eval(['handles.bed_url_' types{i}]);
    elseif ~isfield(handles, 'bed_url_A') & isfield(handles, 'bath_url_A')
        tag = eval(['handles.bath_url_' types{i}]);
    else
        tag = '';
    end
    
    %append tag to url and scrape
    try
        url = ['http://' eval(['handles.city_url_' types{i}]) 'search/apa?' tag];
        html = urlread(url);
        ap_str = 'search/apa?';
    catch err
        switch err.identifier
            case 'MATLAB:urlread:FileNotFound'
                url = ['http://' eval(['handles.city_url_' types{i}]) 'search/aap?' tag];
                html = urlread(url);
                ap_str = 'search/aap?';
            otherwise
                rethrow(err)
        end
    end
    
    %cycle through all pages
    ele_start = strfind(html,'"totalcount"');
    sub_html = html(ele_start(1):ele_start(1)+100);
    ele_end = strfind(sub_html,'</span></span>');
    elements = sub_html(14:ele_end-1);
    num_pages = ceil(str2num(elements)/100);
    
    n=1;
    price = zeros(size(elements));
    for j=1:num_pages
        if j==1
            url_new = url;
        else
            url_new = ['http://' eval(['handles.city_url_' types{i}]) ap_str ...
                's=' mat2str((j-1)*100) tag];
        end
        html_new = urlread(url_new);
        klist = strfind(html_new,'"price">$');
        for m = 1:length(klist)
            k = klist(m);
            p_st = strfind(html_new(k:k+20),'$');
            p_end = strfind(html_new(k:k+20),'<');
            price(n) = str2double(html_new(k+p_st:k+p_end-2));
            n=n+1;
        end
    end
    
    eval(['price_' types{i} '=price;']);
end

make_plots(handles,price_A, price_B);

function make_plots(handles,price_A,price_B)

types = {'A','B'};

for i=1:length(types)
    eval(['price = price_' types{i} ';']);
    eval(['ax = handles.axes_' types{i} ';']);
    
    %throw out outliers at extreme 5% of distributions
    [fn,x] = ecdf(price);
    x_min = min(x(fn > 0.05)); x_max = max(x(fn < 0.95));
    price = price(price >= x_min & price <= x_max);
    
    %plot
    histogram(ax, price);
    xlabel(ax,'Price [$]');
    ylabel(ax,'Number of Listings');
    title(ax,['Median price: $' mat2str(nanmedian(price))]);
    
    %add walkability factor
    t = text(ax,ax.XLim(1),ax.YLim(2)/(-4),...
        ['Walkability factor: ' mat2str(eval(['handles.score_' types{i}]))]);
    set(t,'fontsize',18)
    
end

hold off
