C*VLBOPE -- open a VLB data file [VAX/VMS]
C+
      INTEGER FUNCTION VLBOPE (UNIT, NAME, TYPE, STATUS, RESULT)
      INTEGER UNIT
      CHARACTER*(*) NAME
      CHARACTER*(*) TYPE
      CHARACTER*(*) STATUS
      CHARACTER*(*) RESULT
C
C This routine encapsulates all system-dependent OPEN parameters
C like READONLY, CARRIAGECONTROL in a single subroutine.  Moving to
C a different operating system should require only this routine to be 
C changed, assuming the operating system can cope with Fortran formatted
C and unformatted read and write.
C
C Input arguments:
C   UNIT : Fortran unit number to be used
C   NAME : file name
C   TYPE : file type, one of the strings
C      'MERGE'  merge format
C      'FITS'   disk FITS format (image or uvfits)
C      'MODEL'  model file (text)
C      'TEXT'   arbitrary text file
C   STATUS :
C      'OLD' to open a file for reading (file must already exist)
C      'NEW' to open a new file for writing (file must not already
C            exist, unless the operating system can create a new
C            version)
C
C Output arguments:
C   VLBOPE : receives 1 if the file was opened successfully,
C      0 if the open failed
C   RESULT : receives the full file name, if the file
C      was opened successfully, or am error message (text) if the
C      open failed; the declared length of this variable should
C      be big enough to accommodate the result; 255 bytes should be
C      enough.
C
C Subroutines required:
C   ERROR
C   LEN1
C   PUTOUT
C   ERRSNS (VMS)
C   SYS$GETMSG (VMS)
C
C History:
C   1988 Jun 9 - TJP.
C-----------------------------------------------------------------------
      INTEGER ITYPE, ISTAT, IER, K1, K2, K3, K4, K5, LENERR
      INTEGER LEN1
      CHARACTER*11 FMT
      CHARACTER*4  CC
      CHARACTER*80 STRING
C
C Verify the TYPE argument.
C
      IF (TYPE.EQ.'MERGE') THEN
          ITYPE = 1
          FMT = 'UNFORMATTED'
          CC = 'NONE'
      ELSE IF (TYPE.EQ.'FITS') THEN
          ITYPE = 2
          FMT = 'UNFORMATTED'
          CC = 'NONE'
      ELSE IF (TYPE.EQ.'MODEL' .OR. TYPE.EQ.'TEXT') THEN
          ITYPE = 3
          FMT = 'FORMATTED'
          CC = 'LIST'
      ELSE
          CALL ERROR('VLBOPE: invalid argument TYPE='//TYPE)
      END IF
C
C Verify the STATUS argument.
C
      IF (STATUS.EQ.'OLD') THEN
          ISTAT = 1
      ELSE IF (STATUS.EQ.'NEW') THEN
          ISTAT = 2
      ELSE
          CALL ERROR('VLBOPE: invalid argument STATUS='//STATUS)
      END IF
C
C Attempt to open the file.
C
      IF (ISTAT.EQ.1) THEN
C         -- 'OLD' file
          IF (ITYPE.EQ.2) THEN
              OPEN (UNIT=UNIT, FILE=NAME, READONLY, STATUS='OLD',
     1              RECORDTYPE='FIXED', RECL=720,
     2              FORM=FMT, IOSTAT=IER)
          ELSE
              OPEN (UNIT=UNIT, FILE=NAME, READONLY, STATUS='OLD',
     1              FORM=FMT, IOSTAT=IER)
          END IF
      ELSE
C         -- 'NEW' file
          OPEN (UNIT=UNIT, FILE=NAME, STATUS='NEW',
     1          FORM=FMT, CARRIAGECONTROL=CC, IOSTAT=IER)
      END IF
C
C Success: find the complete file name.
C
      IF (IER.EQ.0) THEN
          INQUIRE (UNIT=UNIT, NAME=RESULT)
          VLBOPE = 1
C
C Failure: determine the error, and issue a message.
C
      ELSE
          IF (ISTAT.EQ.1) THEN
              CALL PUTOUT('++ Cannot find '//TYPE//' file: '//
     1                NAME(1:LEN1(NAME)))
          ELSE
              CALL PUTOUT('++ Cannot create '//TYPE//' file: '//
     1                NAME(1:LEN1(NAME)))
          END IF
          CALL ERRSNS(K1,K2,K3,K4,K5)
          IF (K2.NE.0) THEN
              CALL SYS$GETMSG(%VAL(K2),LENERR,STRING,,)
              CALL PUTOUT(STRING(1:LENERR))
          ELSE
              STRING = 'unknown error'
          END IF
          RESULT = STRING
          VLBOPE = 0
      END IF
C-----------------------------------------------------------------------
      END
