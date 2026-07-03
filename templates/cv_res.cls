\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{cv_res}[2026/03/11 basic curriculum vitae / resumé class]

% Load base class
\LoadClass{article}
%%% Preliminary declarations
% Page sizing
\RequirePackage{geometry} % to change the page dimensions
\geometry{a4paper} % or letterpaper (US) or a5paper or....
\geometry{margin=1.5cm}

\RequirePackage{expl3}
\RequirePackage{kvoptions}
% Declare key-value options
\SetupKeyvalOptions{
	family=myclass,
	prefix=myclass@
}
\RequirePackage{ifthen}
\RequirePackage{enumitem}
\RequirePackage{pgffor}
\RequirePackage{etoolbox}
\RequirePackage{xparse}
\RequirePackage{graphicx}
\RequirePackage{tcolorbox}
\tcbuselibrary{skins}
\RequirePackage{fontawesome7}
\RequirePackage{tikz}
\usetikzlibrary{
	calc,
	shapes.geometric
}
\RequirePackage{xcolor}
\RequirePackage{multirow}
\RequirePackage{hyperref}
% NOTE: maybe add a class option to set the date format?
\RequirePackage[english]{datetime2}
\DTMnewdatestyle{mmmyyyy}{
	\renewcommand*{\DTMdisplaydate}[4]{\DTMenglishmonthname{##2}~{##1}}%
	\renewcommand*{\DTMDisplaydate}{\DTMdisplaydate}%
}
\DTMsetdatestyle{mmmyyyy}

%% Declare options
% NOTE: what options do i want to have?
% - style?
% - accent color
% \DeclareStringOption [⟨init⟩] {⟨key⟩} [⟨default⟩]
\DeclareStringOption[EN]{lang}
\DeclareStringOption[blue]{themeColor}
\DeclareStringOption[0]{titleStyle}
\DeclareStringOption[0]{jobExpStyle}
\DeclareStringOption[0]{eduStyle}
\ProcessKeyvalOptions*
% In LaTeX, you can define class options to change command styles, such as using `\DeclareOption{green}{\renewcommand{\headlinecolor}{\color{green}}}` to alter the `\headlinecolor` command based on the class option specified.

\ifthenelse{\equal{\myclass@themeColor}{blue}}{%
	\definecolor{primaryColor}{RGB}{0, 43, 128}%
	\definecolor{secondary}{RGB}{204, 229, 255}%
}{%
	\ifthenelse{\equal{\myclass@themeColor}{green}}{%
		\definecolor{primaryColor}{RGB}{0, 153, 0}%
		\definecolor{secondary}{RGB}{204, 255, 204}%
	}{%
		\ifthenelse{\equal{\myclass@themeColor}{red}}{%
			\definecolor{primaryColor}{RGB}{204, 0, 0}%
			\definecolor{secondary}{RGB}{255, 204, 204}%
		}{%
			\definecolor{primaryColor}{RGB}{0, 102, 204}%
			\definecolor{secondary}{RGB}{204, 229, 255}%
		}%
	}%
}

\newcommand{\Section}[1]{\section*{\textcolor{primaryColor}{\textbf{#1}}}}

%%% General Helper Functions
% Simple placeholder image, based on
% https://gist.github.com/dpgettings/9635856
\newcommand{\placeholderimage}[4]{
	\fbox{\begin{minipage}[#3][#1][c]{#2}%
		\centering{#4}
	\end{minipage}}
}

%%% Personal Information Commands
\newcommand*{\name}[1]{\gdef\@name{#1}}
\newcommand*{\@name}{$\langle$\texttt{Name}$\rangle$}
\newcommand*{\birthday}[1]{\gdef\@birthday{#1}}
\newcommand*{\birthplace}[1]{\gdef\@birthplace{#1}}
\newcommand*{\nationality}[1]{\gdef\@nationality{#1}}
\newcommand*{\familyStatus}[1]{\gdef\@familyStatus{#1}}
\newcommand*{\address}[3]{\gdef\@addressStreet{#1}\gdef\@addressZIP{#2}\gdef\@addressCity{#3}}
\newcommand*{\phone}[1]{\gdef\@phone{#1}}
\newcommand*{\email}[1]{\gdef\@email{#1}}
\newcommand*{\githubLink}[1]{\gdef\@githubLink{#1}}
\newcommand*{\@githubLink}{}
\newcommand*{\profilepicture}[1]{\gdef\@profilepicture{#1}}
\newcommand*{\@profilepicture}{}
% Set default values based on language
% TODO: consider changing this to str_case?
\ifthenelse{\equal{\myclass@lang}{EN}}{%
	\newcommand*{\@birthday}{$\langle$\texttt{Birthday}$\rangle$}
	\newcommand*{\@birthplace}{$\langle$\texttt{Birthplace}$\rangle$}
	\newcommand*{\@nationality}{$\langle$\texttt{Nationality}$\rangle$}
	\newcommand*{\@familyStatus}{$\langle$\texttt{Family Status}$\rangle$}
	\newcommand*{\@addressStreet}{$\langle$\texttt{Address}$\rangle$}
	\newcommand*{\@addressZIP}{$\langle$\texttt{ZIP code}$\rangle$}
	\newcommand*{\@addressCity}{$\langle$\texttt{City}$\rangle$}
	\newcommand*{\@phone}{$\langle$\texttt{Phone Number}$\rangle$}
	\newcommand*{\@email}{$\langle$\texttt{E-Mail Address}$\rangle$}
}{%
	\newcommand*{\@birthday}{$\langle$\texttt{Geburtsdatum}$\rangle$}
	\newcommand*{\@birthplace}{$\langle$\texttt{Geburtsort}$\rangle$}
	\newcommand*{\@nationality}{$\langle$\texttt{Staatsangehörigkeit}$\rangle$}
	\newcommand*{\@familyStatus}{$\langle$\texttt{Familienstand}$\rangle$}
	\newcommand*{\@addressStreet}{$\langle$\texttt{Address}$\rangle$}
	\newcommand*{\@addressZIP}{$\langle$\texttt{ZIP code}$\rangle$}
	\newcommand*{\@addressCity}{$\langle$\texttt{City}$\rangle$}
	\newcommand*{\@phone}{$\langle$\texttt{Mobilnummer}$\rangle$}
	\newcommand*{\@email}{$\langle$\texttt{E-Mail-Adresse}$\rangle$}
}


%%%%%  ~~~~~~~~~~~~~~~~~~~~   (re)Create maketitle   ~~~~~~~~~~~~~~~~~~~~  %%%%%
\ExplSyntaxOn
\renewcommand*{\maketitle}{
\str_case:VnF{ \myclass@titleStyle }{
	{ 0 }{% begin title 0
\begin{center}
	\Large
	\textbf{\@name}
\end{center}
\ifx\@phone\undefined
% https://en.wikibooks.org/wiki/TeX/if
\noindent\@addressStreet,~\@addressZIP\hspace*{4pt}\@addressCity\hfill\hfill\@email
\else
\noindent\@addressStreet,~\@addressZIP\hspace*{4pt}\@addressCity\hfill**\hfill\@phone\hfill**\hfill\@email
\fi
\vspace{2pt}
\hrule~height~1pt
\begin{flushright}
	% This solution to eliminating the space before the date feels a bit hacky...
	\setlength{\parskip}{-3mm}
	\textit{\DTMtoday}
\end{flushright}
	}% end title 0
	{ 1 }{% begin title 1: originally DE CV
\Section{Persönlich~Daten}
% table with 1 column next to an image
\newsavebox{\tableBox}%
\newlength{\tableHeight}%
% https://tex.stackexchange.com/questions/66425/tabular-height-savebox-problem/66429#66429
\savebox{\tableBox}[0.562\textwidth]{%
	\vspace{2pt}%
	\large
	\begin{tabular}[b]{l p{6cm}}
		Name & \@name \\
		Geburtsdatum & \@birthday \\
		Geburtsort & \@birthplace \\
		Staatsangehörigkeit & \@nationality \\
		Familienstand & \@familyStatus \\
		Anschrift & \@addressStreet \\
							& \@addressZIP\hspace*{4pt}\@addressCity \\
		Mobil & \@phone \\
		Mail & \@email \\
		LinkedIn & www.linkedin.com/in/...
	\end{tabular}
}%
\settoheight{\tableHeight}{\usebox{\tableBox}}
\usebox{\tableBox}%
\hfil%
\ifdefempty{\@profilepicture}{%
	\placeholderimage{\tableHeight}{0.2\textwidth}{b}{$\langle$Profilbild$\rangle$}
}{\includegraphics[height=\tableHeight]{\@profilepicture}}
	}% end title 1
	{ 2 }{% begin title 2: DE Resume
\noindent
\begin{minipage}[t]{0.32\textwidth}%
	\vspace{0pt}%
	\centering%
\ifdefempty{\@profilepicture}{%
	\placeholderimage{}{0.9\textwidth}{b}{$\langle$Profilbild$\rangle$}
}{%
	\vspace{-6mm}
	% Round cropped picture
	\begin{tikzpicture}
		\clip (0,0) ellipse (14mm~and~18mm);
		\node at (0,0) {
			\includegraphics[trim={36~36~41~2}, clip=true, width=0.45\textwidth]{\@profilepicture}};
		\end{tikzpicture}%
}
\end{minipage}%
\hfil%
\begin{minipage}[t]{0.32\textwidth}
	\vspace{0pt}%
	\begin{center}
		\vspace{6mm}
		\huge\@name%
		\par
		% \@title
	\end{center}
\end{minipage}%
\hfil%
\begin{minipage}[t]{0.32\textwidth}
	\vspace{0pt}%
	\begin{tabular}[t]{c p{6cm}}
		\faCakeCandles & \@birthday \\
		\faFlag & \@nationality \\
		\multirow{2}{*}{\faLocationDot} & \@addressStreet \\
																		& \@addressZIP\hspace*{4pt}\@addressCity \\
		\textbf{\large @} & \small\@email \\
		\faPhone & \@phone \\
		\ifdefempty{\@githubLink}{}{\faGithub & \url{\@githubLink} \\}
	\end{tabular}
\end{minipage}
	}% end title 2
}{ No~titleStyle? }
}
\ExplSyntaxOff

\tcbset{%
	dotline/.style={%
		blanker,
		box align=top,
		left=3mm, top=-1.4mm,
		valign=top,
		borderline west={0.3mm}{-0.1mm}{primaryColor},
		overlay={\draw[fill=primaryColor] (frame.north west) circle (3.2pt);}
	}
}

%%%%%  ~~~~~~~~~~~~~~~~~~~~  Employment Information  ~~~~~~~~~~~~~~~~~~~~  %%%%%
%% Employment entry
% End-of-list, position, organization, location, duration(s), responsibilities
\ExplSyntaxOn
\NewDocumentCommand{\employmentEntry}{s m m d[] m m}{%
\str_case:VnF{ \myclass@jobExpStyle }{
	{ 0 }{% begin employmentEntry 0
\parbox{\textwidth}{
	\par\noindent\textbf{#3,~#2}%
	\par\noindent#5
	\begin{itemize}[noitemsep,nolistsep]
		% https://stackoverflow.com/a/3281778
		\foreach \task in {#6}{\item \task}
	\end{itemize}
	\bigskip
}
	}% end 0
	{ 1 }{% begin employmentEntry 1: originally DE CV
\parbox{\textwidth}{\large
	\IfValueTF{#4}{%
		\par\noindent\underline{#3,~#4}~#2%
	}{%
		\par\noindent\underline{#3}~#2%
	}
	\par
	\begin{minipage}{0.19\textwidth}
		\begin{itemize}[noitemsep,nolistsep,leftmargin=0pt]
			% https://stackoverflow.com/a/3281778
			\foreach \dateEntry in {#5}{\item[] \dateEntry}
		\end{itemize}
	\end{minipage}
	\hfil
	\begin{minipage}{0.80\textwidth}
		\begin{itemize}[noitemsep,nolistsep]
			\foreach \task in {#6}{\item\task}
		\end{itemize}
	\end{minipage}
	\bigskip
}
	}% end 1
	{ 2 }{% begin employmentEntry 2: originally DE resume
\IfBooleanTF{#1}{\edef\@bottomStretch{0.0mm}}{\edef\@bottomStretch{6.5mm}}%
\noindent\parbox{\textwidth}{%
	\begin{minipage}[t]{0.22\textwidth}%
		\raggedright\textbf{#2}
		\begin{itemize}[
			label={},
			labelindent=0pt,
			nolistsep,
			leftmargin=0pt]%
			% https://stackoverflow.com/a/3281778
			\foreach \dateEntry in {#5}{\item\dateEntry}%
		\end{itemize}%
	\end{minipage}%
	\hfil%
	\begin{minipage}[t]{0.77\textwidth}%
		\vspace{-1.0mm}\vspace{-\@bottomStretch}%
		\begin{tcolorbox}[dotline, enlarge~bottom~by=-\@bottomStretch]%
			\IfValueTF{#4}{\par\noindent \textbf{#3~(#4)}}{\par\noindent\textbf{#3}}%
			\vspace{1mm}\raggedright%
			\begin{itemize}[noitemsep,nolistsep,leftmargin=4mm]%
				\foreach \task in {#6}{\item[-]\task}%
			\end{itemize}%
			\vspace{\@bottomStretch}%
		\end{tcolorbox}%
	\end{minipage}%
	\IfBooleanTF{#1}{\smallskip}{\bigskip}
}
	}% end 2
}{ No~jobExpStyle? }
}
\ExplSyntaxOff

%%%%%  ~~~~~~~~~~~~~~~~~~~~  Education Information  ~~~~~~~~~~~~~~~~~~~~  %%%%%
%% Define education entry
% end-of-list, School, [department], date, degree, GPA
% NOTE: consider expanding to include location optional argument?
\ExplSyntaxOn
\NewDocumentCommand{\educationEntry}{s m d[] m m m}{%
\str_case:VnF{ \myclass@eduStyle }{
	{ 0 }{% begin educationEntry 0
\parbox{\textwidth}{%
	\noindent\textbf{\IfValueTF{#3}{#2,~#3}{#2}}
	% TODO: make the spacing dynamic...
	\par\noindent #5\hfill#6\hspace{0.3\textwidth}#4\bigskip
}
	}% end 0
	{ 1 }{% begin educationEntry 1
\parbox{\textwidth}{%
	\noindent\large\underline{\IfValueTF{#3}{#2,~#3}{#2}}%
	% TODO: make the spacing dynamic...
	\par\noindent #4\hfill#5\hspace{10mm}#6\bigskip
}
	}% end 1
	{ 2 }{% educationEntry 2
\IfBooleanTF{#1}{\edef\@bottomStretch{0.0mm}}{\edef\@bottomStretch{9.5mm}}%
\parbox{\textwidth}{%
	\begin{minipage}[t]{0.22\textwidth}%
		\raggedright\textbf{#5}\par#4%
	\end{minipage}%
	\hfil%
	\begin{minipage}[t]{0.77\textwidth}%
		\vspace{-1.0mm}\vspace{-\@bottomStretch}%
		\begin{tcolorbox}[dotline,
			enlarge~bottom~by=-\@bottomStretch]%
			\textbf{#2}\par%
			\IfValueTF{#3}{#3\hfill#6}{\hfill#6}%
			\vspace{\@bottomStretch}%
		\end{tcolorbox}%
	\end{minipage}%
	\IfBooleanTF{#1}{\smallskip}{\bigskip}
}
	}% end 2
}{ No~eduStyle? }
}
\ExplSyntaxOff

%%%%%  ~~~~~~~~~~~~~~~~~~~~    Skills Information    ~~~~~~~~~~~~~~~~~~~~  %%%%%
%% Shape functions
% Define shape keys
% Read this for more details: https://tikz.dev/pgfkeys
\pgfkeys{
	/shapeKeys/.is family, % Create the shapeKeys grouping/family
	/shapeKeys,
	circle/.style={circle},
	square/.style={},
	diamond/.style={diamond},
	star/.style={star, star point height=2.9mm},
	dart/.style={dart}
}
% TODO: add color option
% starShape - * version produces a filled star
\NewDocumentCommand{\skillShape}{s O{black} m}{%
	\IfBooleanTF{#1}{\def\fillStyle{#2}}{\def\fillStyle{none}}%
	\begin{tikzpicture}[scale=0.4, transform shape, baseline=-3pt]
		\node [/shapeKeys/#3, minimum size=7mm, draw=#2, fill=\fillStyle] {};
	\end{tikzpicture}~%
}

%% Count the number of items in a list
% \newcommand{\countItems}[1]{%
% 	\newcounter{c}%
% 	\foreach \i in {#1}{\stepcounter{c}}%
% 	\thec%
% }

% skill name, skill level, shape, optional color? or accent color
\NewDocumentCommand{\skillListEntry}{m m m}{%
	\large%
	#1 & \ifnum #2>0 {\foreach \i in {1,...,#2} {\skillShape*{#3}}}\fi%
		\ifnum #2<5 {\foreach \i in {#2,...,4} {\skillShape{#3}}}\fi\\
	% \smallskip%
}

%% Skill list
% List title, list of skills (name-lvl pairs), filled symbol, hollow symbol
\NewDocumentCommand{\skillList}{o m m}{%
	% NOTE: renew-do must be outside of tabular environment,
	% otherwise only the first item in the list will be processed
	% NOTE: \do only ever has 1 argument
	\RenewDocumentCommand{\do}{>{\SplitArgument{1}{,}}m}{\skillListEntry##1{#3}}
	\def\arraystretch{1.2}%
\begin{tabular}{ll}
	\IfValueT{#1}{\multicolumn{2}{l}{\large#1} \\}
	\hline
	% NOTE: For info on \docsvlist, see
	% https://ctan.net/macros/latex/contrib/etoolbox/etoolbox.pdf
	\docsvlist{#2}
\end{tabular}
}

% Suppress page numbers
\pagestyle{empty}
