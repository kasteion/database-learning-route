# RESTORING A DATABASE

The principal reason we take backups of system and user defined databases is that it allows us to restore the databases in case of disaster. There are a few restore commands that we should be familiar with and they are as follows:

## RESTORE COMMANDS

- **RESTORE DATABASE**: Allows us to restore a full, differential, file or filegroup backup.
- **RESTORE LOG**: Allows us to restore a transaction log backup

## INFORMATIONAL RESTORE COMMANDS

- **RESTORE HEADERSONLY**: Gives you a list of all the backups in a file.
- **RESTORE FILELISTONLY**: Gives you a list of all of the files that were backed up for a given backup.
- **RESTORE VERIFYONLY**: Verifies that the backup is readable by the RESTORE process.
- **RESTORE LABELONLY**: Gives you the backup media information.

## RESTORE HEADERONLY

The RESTORE HEADERONLY option allows you to see the backup header information for all backups for a particular backup device.

**Example**

```
RESTORE HEADERONLY FROM DISK = 'C:\backups\test.bak'
GO
```

## RESTORE FILELISTONLY

The RESTORE FILELISTONLY option allows you to see a list of the files that were backed up such as the .mdf and .ldf

**Example**

```
RESTORE FILELISTONLY FROM DISK = 'C:\backups\test.bak'
GO
```

## RESTORE VERIFYONLY

Verifies that the backup is readable by the RESTORE process

**Example**

```
RESTORE VERIFYONLY from disk = 'C:\backups\test.bak'
GO
```

## RESTORE LABELONLY

The RESTORE LABELONLY option allows you to see the backup media information for the backup device.

## RECOVERY OPTIONS

**RESTORE WITH RECOVERY**
When there are no extra files to restore the database.

**RESTORE WITH NORECOVERY**
When we are restoring and we have many files. We reach a file number but we have more files to restore.
