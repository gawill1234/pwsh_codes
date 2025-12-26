Imports System.Net
Imports System.IO
Imports System.Globalization
Imports System.Collections.Generic

''' <summary>
''' This class is used to record the details of a single web access.
''' </summary>
Public Class WebAccess
    Private m_document As String      ' the document that was accessed
    Private m_referer As String       ' url of page that refered to the document
    Private m_accessTime As DateTime  ' the time of access in GMT
    Public Sub New(ByVal time As DateTime, ByVal document As String, _
                   ByVal referer As String)
        Me.AccessTime = time
        Me.Document = document
        Me.Referer = referer
    End Sub
    Public Property AccessTime() As DateTime
        Get
            Return m_accessTime
        End Get
        Set(ByVal value As DateTime)
            m_accessTime = value
        End Set
    End Property
    Public Property Document() As String
        Get
            Return m_document
        End Get
        Set(ByVal value As String)
            m_document = value
        End Set
    End Property
    Public Property Referer() As String
        Get
            Return m_referer
        End Get
        Set(ByVal value As String)
            m_referer = value
        End Set
    End Property
End Class

''' <summary>
''' Parser for parsing IIS log files.
''' </summary>
Public Class LogParser
    Private m_dateFieldIndex As Integer
    Private m_timeFieldIndex As Integer
    Private m_documentFieldIndex As Integer
    Private m_refererFieldIndex As Integer

    ''' <summary>
    ''' Parse the line that contains field order.
    ''' </summary>
    ''' <param name="line">The line that contains the field order.</param>
    ''' <remarks>Not all log files contain all fields, and fields may not be
    ''' in a pre-defined order. The log file contains a comment line which lists
    ''' the fields present, and the order in which the fields appear. This 
    ''' method is used for extracting the field order from that line.</remarks>
    Private Sub ParseFieldOrder(ByVal line As String)
        m_dateFieldIndex = -1
        m_timeFieldIndex = -1
        m_documentFieldIndex = -1
        m_refererFieldIndex = -1
        Dim fieldNames As String() = line.Split(" ")
        Dim i As Integer
        For i = 1 To fieldNames.Length - 1
            Select Case fieldNames(i)
                Case "date"
                    m_dateFieldIndex = i - 1
                Case "time"
                    m_timeFieldIndex = i - 1
                Case "cs-uri-stem"
                    m_documentFieldIndex = i - 1
                Case "cs(Referer)"
                    m_refererFieldIndex = i - 1
            End Select
        Next
    End Sub

    ''' <summary>
    ''' Parse a log file and return its contents.
    ''' </summary>
    ''' <param name="logFilename">Name of log file.</param>
    ''' <returns>A collection of WebAccess objects.</returns>
    ''' <remarks></remarks>
    Public Function Parse(ByVal logFilename As String) As List(Of WebAccess)
        Dim reader As StreamReader = Nothing
        Dim line As String
        Dim fields As String()
        Dim en As New CultureInfo("en-US")
        Dim format As New String("yyyy-MM-dd HH:mm:ss")
        Dim accessList As New List(Of WebAccess)
        Dim ignoredTypes As String() = {".gif", ".jpg", ".dll", ".js", ".css"}

        Try
            reader = New StreamReader(logFilename)
            Do
                line = reader.ReadLine()
                If line Is Nothing Then
                    Exit Do
                End If
                If line.StartsWith("#") Then
                    ParseFieldOrder(line)
                Else
                    fields = line.Split(" ")
                    Dim dateTimeStr As String = _
                          fields(m_dateFieldIndex) & " " & fields(m_timeFieldIndex)
                    Dim time As DateTime = _
                          DateTime.ParseExact(dateTimeStr, format, en.DateTimeFormat)
                    Dim referer As String = fields(m_refererFieldIndex)
                    Dim document As String = fields(m_documentFieldIndex)
                    Dim extension As String = Path.GetExtension(document)
                    If Array.IndexOf(ignoredTypes, extension) = -1 Then
                        accessList.Add(New WebAccess(time, fields(m_documentFieldIndex), referer))
                    End If
                End If
            Loop
            Return accessList
        Finally
            If Not (reader Is Nothing) Then
                reader.Close()
            End If
        End Try
    End Function

    ''' <summary>
    ''' Parse supplied log file.
    ''' </summary>
    ''' <param name="logFile">Name of file to parse.</param>
    ''' <returns>Web accesses logged in the file.</returns>
    ''' <remarks></remarks>
    Public Shared Function ParseLogFile(ByVal logFile As String) As List(Of WebAccess)
        Dim parser As New LogParser
        Return parser.Parse(logFile)
    End Function
End Class

