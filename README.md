Wihlo
=====

Wihlo was created out of my frustration with the lack of a simple, good quality Linux weather station application for the Davis Vantage Pro2. At the moment it is still very much a work in progress, and as such is not ready for general use. Please keep checking back here for updates, or if you want further information please email andy@andybev.com

Features
--------
* Display configurable weather graphs in a web browser
* Download data from a Vantage Pro2
* Import data from wview

Timezones
---------
Wihlo stores all times in the database as UTC. However, converting local times from a data logger into UTC can be difficult, when the timezone information is not fully known. The following section lists any specific datalogger issues.

### VantagePro2
* If possible, it is recommended that you set the VP2 datalogger for a named timezone, not an offset from GMT, and keep this consistent. This is because the time field contained in a VP2 record is a local time, with no information as to its timezone.
* When downloading a set of records, Wihlo first asks the datalogger for its timezone. This information is used to convert the times of all the records received into a UTC time.
* If the timezone is a named timezone (as recommended), then this is used to compensate for DST, if required.
* If the timezone is simply an offset from GMT, then Wihlo queries the datalogger as to whether its internal clock is set to DST. If it is, then the time for each record is further adjusted to compensate. Therefore, when changing the local time on the VP2 to copmensate for DST, you should download all records before making the change, otherwise the time of the earlier records will be changed incorrectly for DST.
* Because the VP2 uses the local time in a download record, sometimes a record will contain exactly the same time as a previous record (if the clocks have gone back by an hour). Wihlo tries to spot this, by monitoring for times in records received during such "go back" hours: the first record received will be assumed to be in DST; Wihlo will jump to standard time once a record is received that has a time earlier than one already received.
* If importing from a wview database, it is assumed that the time in the wview database is already in UTC. It should be noted that wview calcuates UTC based on the local computer's timezone, not the timezone of the VP2 datalogger. Therefore, if the timezone on the computer that the VP2 is connected to is different to the timezone of the VP2 itself, then the times imported will probably be incorrect.


