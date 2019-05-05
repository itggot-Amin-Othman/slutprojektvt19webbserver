# slutprojektvt19webbserver

# Projektplan

## 1. Projektbeskrivning
En grym webb kalkylator med LaTeX
Man kan göra kalkulationer och andra kan se de samt like'a de.
## 2. Vyer (sidor)
Första sidan med "Log in" och "Create".

Profil sida med kalkylator, historik samt knappar för att spara historik, radera historik, radera profilen, logga u och gå till allas historik.

Historik sidan, Visa upp allas beräkningar med vem som gjort den, hur många likes den har samt en like knapp.
## 3. Funktionalitet (med sekvensdiagram)
Kalkylator med sqrt, int, M.M (en avancerad helt enklet)
Auto uppdaterar efter vad du skriver.
https://bit.ly/2FsytBW
## 4. Arkitektur (Beskriv filer och mappar)
Controller.rb
Model.rb
Views
   Layout.slim
   Error
        forbidden.slim
        nope.slim
   Profile
        profile.slim
   Shared
        comrades.slim
        index.slim
Public 
    Css
        mein.css
    Img
        *massa bilder*
    Js
        mathlex.js
        calculator.js
        jquery.js
DB
    slutarbdb.db    


## 5. (Databas med ER-diagram)
https://bit.ly/2HY6pJy 
(Uppdarad db)

calculations
    CalcId
    UserId
    Calculation
likes
    UserId
    CalcId
users
    UserId
    Username
    Password
