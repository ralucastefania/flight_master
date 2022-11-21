# flight_master

Requests:

Phase 1: Create a report with a print list
- Executable report with selection screen
- Selection criteria 1: Date from
- Selection criteria 2: Date to
- Selection criteria 3: All existing carriers with default Lufthansa
- Selection criteria 4: Planetype
- Selection criteria 5: Minimum of free seats
- Result upon execution: Write list on screen

Phase 2: Encapsulate the logic in an API class
- Create static API methods and only call them in the report
- Buffer data on the class in a buffer - only fields really required
- Only use one single Select on DB

Phase 3: Freestyle extension phase
- Selection criteria 3 should be a dropdown/listbox
- Selection criteria 4 should be a dropdown/listbox, values should change/depend on selection criteria 3
- Switch from Write List to ALV
- Raise error messages and prevent "stupid requests"
- Check the usage of events like start of selection or initialization in the report

My add-ons:
- Change the method calls to the new syntax
- Take doubles out of the airplane types 
- Clear airplanes type list when the selected airline changes
- Added destination city (read from another data base table)
- Custom title for the ALV
- Hide mandant column
- Show number of free seats
- Show only airlines that have data
- Add ALV toolbar
- Display stripes
- Custom report title 
- Use aggregation for flight dates
