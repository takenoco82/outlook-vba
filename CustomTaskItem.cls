VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "CustomTaskItem"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

' ==========================================================
' �萔
' ==========================================================
' ���t�̏����l(��̓��t�̒l)
Const EMPTY_DATE_VALUE As Date = #1/1/4501#

' ���[�U�[��`�t�B�[���h[�v���W�F�N�g]�̖��O
Const USER_PROPERTY_NAME_PROJECT As String = "�v���W�F�N�g"
' ���[�U�[��`�t�B�[���h[�J�n����]�̖��O
Const USER_PROPERTY_NAME_ACTUAL_START_TIME As String = "�J�n����"
' ���[�U�[��`�t�B�[���h[�I������]�̖��O
Const USER_PROPERTY_NAME_ACTUAL_END_TIME As String = "�I������"
' ���[�U�[��`�t�B�[���h[���ώ���]�̖��O
Const USER_PROPERTY_NAME_ESTIMATED_TIME As String = "���ώ���"
' ���[�U�[��`�t�B�[���h[��Ǝ���]�̖��O
Const USER_PROPERTY_NAME_ACTUAL_WORK_TIME As String = "��Ǝ���"


' ==========================================================
' �N���X�ϐ�
' ==========================================================
' �^�X�N
Private MyTask As Outlook.TaskItem
' ���[�U�[��`�t�B�[���h[�v���W�F�N�g]
Private MyProject As Outlook.UserProperty
' ���[�U�[��`�t�B�[���h[�J�n����]
Private MyActualStartTime As Outlook.UserProperty
' ���[�U�[��`�t�B�[���h[�I������]
Private MyActualEndTime As Outlook.UserProperty
' ���[�U�[��`�t�B�[���h[���ώ���]
Private MyEstimatedTime As Outlook.UserProperty
' ���[�U�[��`�t�B�[���h[��Ǝ���]
Private MyActualWorkTime As Outlook.UserProperty


' ==========================================================
' ���\�b�h
' ==========================================================
' ��������
Public Function Init(ByRef aTask As Outlook.TaskItem) As CustomTaskItem
    Set MyTask = aTask
    Debug.Print "CustomTaskItem#Init(): " & ToString()
    Set Init = Me
End Function

' ��Ǝ��Ԃ��L�^����
Public Function RecordTime() As CustomTaskItem
    ' ����                 �� ��Ǝ��Ԃ̋L�^���ĊJ����
    ' ������(�J�n��������) �� ��Ǝ��Ԃ̋L�^���J�n����
    ' �i�s��(�I����������) �� ��Ǝ��Ԃ̋L�^���~����
    ' ��L�ȊO             �� ��Ǝ��Ԃ̋L�^���ĊJ����
    
    If Status = olTaskComplete Then
        Set RecordTime = ReStartTime()
    ElseIf ActualStartTime = EMPTY_DATE_VALUE Then
        Set RecordTime = StartTime()
    ElseIf ActualEndTime = EMPTY_DATE_VALUE Then
        Set RecordTime = StopTime()
    Else
        Set RecordTime = ReStartTime()
    End If
End Function

' ��Ǝ��Ԃ̋L�^���J�n����
Public Function StartTime() As CustomTaskItem
    ActualStartTime = Now()
    Status = olTaskInProgress
    
    Call MyTask.Save
    Set StartTime = Me
End Function

' ��Ǝ��Ԃ̋L�^���~����
Public Function StopTime() As CustomTaskItem
    ActualEndTime = Now()
    Status = olTaskInProgress
    
    Call MyTask.Save
    Set StopTime = Me
End Function

' ��Ǝ��Ԃ̋L�^���ĊJ����
Public Function ReStartTime() As CustomTaskItem
    ' �����ƌ��̃^�X�N�������ɂȂ��Ă��܂��̂Ń_��
    ' Set ReStartTime = Complete().Copy().NotStarted().StartTime()

    ' ���ώ��Ԃ��R�s�[����ƌ�ŏW�v����Ƃ��ɖʓ|�Ȃ��ƂɂȂ�̂ŁA���ώ��Ԃ̓��Z�b�g����
    ' �f�[�^�͈ȉ��̂悤�ȃC���[�W�ɂȂ�
    '
    ' ���   ���ώ��� �J�n���� �I������
    ' ----   -------- -------- --------
    ' ��ƒ� 1H       10:00    11:00
    '
    ' ��
    ' �� 13:00 �ɍĊJ
    ' ��
    '
    ' ���   ���ώ��� �J�n���� �I������
    ' ----   -------- -------- --------
    ' ��ƒ� 1H       13:00             �� ���̃^�X�N
    ' ����            10:00    11:00    �� �R�s�[�����^�X�N

    Dim NewCustomTask As CustomTaskItem
    Set NewCustomTask = Copy().Complete().ResetEstimatedTime()
    
    ' ���̃^�X�N�𖢒���ɂ��č�Ǝ��Ԃ̋L�^���J�n����
    Set ReStartTime = NotStarted().StartTime()
End Function

' �^�X�N��������Ԃɂ���
Public Function Complete() As CustomTaskItem
    If Status = olTaskComplete Then
        Set Complete = Me
        Exit Function
    End If
    
    If ActualStartTime = EMPTY_DATE_VALUE Then
        ActualStartTime = Now()
    End If
    If ActualEndTime = EMPTY_DATE_VALUE Then
        ActualEndTime = Now()
    End If
    Call MyTask.MarkComplete
    
    Call MyTask.Save
    Set Complete = Me
End Function

' �^�X�N�𖢒����Ԃɂ���
Public Function NotStarted() As CustomTaskItem
    ActualStartTime = EMPTY_DATE_VALUE
    ActualEndTime = EMPTY_DATE_VALUE
    Status = olTaskNotStarted
    
    Call MyTask.Save
    Set NotStarted = Me
End Function

' ���тƌ��ς����Z�b�g����
Public Function Reset() As CustomTaskItem
    ActualStartTime = EMPTY_DATE_VALUE
    ActualEndTime = EMPTY_DATE_VALUE
    Status = olTaskNotStarted
    EstimatedTime = 0
    
    Call MyTask.Save
    Set Reset = Me
End Function

' ����(��Ǝ��Ԃ̋L�^)�����Z�b�g����
Public Function ResetActualTime() As CustomTaskItem
    ActualStartTime = EMPTY_DATE_VALUE
    ActualEndTime = EMPTY_DATE_VALUE
    
    Call MyTask.Save
    Set ResetActualTime = Me
End Function

' ���ώ��Ԃ����Z�b�g����
Public Function ResetEstimatedTime() As CustomTaskItem
    EstimatedTime = EMPTY_DATE_VALUE
    
    Call MyTask.Save
    Set ResetEstimatedTime = Me
End Function

' ���ލ��ڂ����Z�b�g����
Public Function ResetCategories() As CustomTaskItem
    Categories = ""
    
    Call MyTask.Save
    Set ResetCategories = Me
End Function

' �^�X�N���R�s�[����
Public Function Copy() As CustomTaskItem
    Dim NewTask As Outlook.TaskItem
    Set NewTask = MyTask.Copy
    
    Set Copy = CustomTaskItemFactory.GetInstance(NewTask)
End Function

' �^�X�N���ړ�����
Public Function Move(ByVal aFolderName As String) As CustomTaskItem
    Dim DestFolder As Outlook.Folder
    Set DestFolder = Outlook.Application.GetNamespace("MAPI").GetDefaultFolder(olFolderTasks).Folders(aFolderName)
    
    Call MyTask.Move(DestFolder)
    Set Move = Me
End Function

' �^�X�N��ۑ�����
Public Function Save() As CustomTaskItem
    Call MyTask.Save
    Set Save = Me
End Function

' �C���X�^���X�̓��e�𕶎���ŕԋp����(�f�o�b�O�p)
Public Function ToString() As String
    ToString = "Project=" & Project _
        & "," & "Subject=" & Subject _
        & "," & "Status=" & Status _
        & "," & "StartDate=" & StartDate _
        & "," & "DueDate=" & DueDate _
        & "," & "DateCompleted=" & DateCompleted _
        & "," & "ActualStartTime=" & ActualStartTime _
        & "," & "ActualEndTime=" & ActualEndTime _
        & "," & "EstimatedTime=" & EstimatedTime _
        & "," & "Categories=" & Categories
End Function


' ==========================================================
' �v���p�e�B
' ==========================================================
' ����
Public Property Get Subject() As String
    Subject = MyTask.Subject
End Property

Public Property Let Subject(ByVal aSubject As String)
    MyTask.Subject = aSubject
    Call MyTask.Save
End Property

' �J�n��
Public Property Get StartDate() As Date
    StartDate = MyTask.StartDate
End Property

Public Property Let StartDate(ByVal aStartDate As Date)
    MyTask.StartDate = aStartDate
    Call MyTask.Save
End Property

' ����
Public Property Get DueDate() As Date
    DueDate = MyTask.DueDate
End Property

Public Property Let DueDate(ByVal aDueDate As Date)
    MyTask.DueDate = aDueDate
    Call MyTask.Save
End Property

' ������
Public Property Get DateCompleted() As Date
    DateCompleted = MyTask.DateCompleted
End Property

Public Property Let DateCompleted(ByVal aDateCompleted As Date)
    MyTask.DateCompleted = aDateCompleted
    Call MyTask.Save
End Property

' ���
Public Property Get Status() As OlTaskStatus
    Status = MyTask.Status
End Property

Public Property Let Status(ByVal aStatus As OlTaskStatus)
    MyTask.Status = aStatus
    Call MyTask.Save
End Property

' ���ލ���
Public Property Get Categories() As String
    Categories = MyTask.Categories
End Property

Public Property Let Categories(ByVal aCategories As String)
    MyTask.Categories = aCategories
    Call MyTask.Save
End Property

' �v���W�F�N�g
Public Property Get Project() As String
    If Not MyProject Is Nothing Then
        Project = MyProject.Value
        Exit Property
    End If
    
    ' ���[�U�[��`�t�B�[���h�̎擾
    Set MyProject = MyTask.UserProperties.Find(USER_PROPERTY_NAME_PROJECT)
    If Not MyProject Is Nothing Then
        Project = MyProject.Value
        Exit Property
    End If
    
    ' �����܂ŗ���̂̓��[�U��`�t�B�[���h���Ȃ��ꍇ�Ȃ̂ŁA�ǉ����ď���������
    Set MyProject = MyTask.UserProperties.Add(USER_PROPERTY_NAME_PROJECT, olText)
    MyProject.Value = ""
    Call MyTask.Save
    
    Project = MyProject.Value
End Property

Public Property Let Project(ByVal aProject As String)
    If Not MyProject Is Nothing Then
        MyProject.Value = aProject
        Call MyTask.Save
        Exit Property
    End If
    
    ' ���[�U�[��`�t�B�[���h�̎擾
    Set MyProject = MyTask.UserProperties.Find(USER_PROPERTY_NAME_PROJECT)
    If Not MyProject Is Nothing Then
        MyProject.Value = aProject
        Call MyTask.Save
        Exit Property
    End If
    
    ' �����܂ŗ���̂̓��[�U��`�t�B�[���h���Ȃ��ꍇ�Ȃ̂ŁA�ǉ����Ĉ�����ݒ肷��
    Set MyProject = MyTask.UserProperties.Add(USER_PROPERTY_NAME_PROJECT, olText)
    MyProject.Value = aProject
    Call MyTask.Save
End Property

' �J�n����
Public Property Get ActualStartTime() As Date
    If Not MyActualStartTime Is Nothing Then
        ActualStartTime = MyActualStartTime.Value
        Exit Property
    End If
    
    ' ���[�U�[��`�t�B�[���h�̎擾
    Set MyActualStartTime = MyTask.UserProperties.Find(USER_PROPERTY_NAME_ACTUAL_START_TIME)
    If Not MyActualStartTime Is Nothing Then
        ActualStartTime = MyActualStartTime.Value
        Exit Property
    End If
    
    ' �����܂ŗ���̂̓��[�U��`�t�B�[���h���Ȃ��ꍇ�Ȃ̂ŁA�ǉ����ď���������
    Set MyActualStartTime = MyTask.UserProperties.Add(USER_PROPERTY_NAME_ACTUAL_START_TIME, olDateTime)
    MyActualStartTime.Value = EMPTY_DATE_VALUE
    Call MyTask.Save

    ActualStartTime = MyActualStartTime.Value
End Property

Public Property Let ActualStartTime(ByVal anActualStartTime As Date)
    If Not MyActualStartTime Is Nothing Then
        MyActualStartTime.Value = anActualStartTime
        Call MyTask.Save
        Exit Property
    End If
    
    ' ���[�U�[��`�t�B�[���h�̎擾
    Set MyActualStartTime = MyTask.UserProperties.Find(USER_PROPERTY_NAME_ACTUAL_START_TIME)
    If Not MyActualStartTime Is Nothing Then
        MyActualStartTime.Value = anActualStartTime
        Call MyTask.Save
        Exit Property
    End If
    
    ' �����܂ŗ���̂̓��[�U��`�t�B�[���h���Ȃ��ꍇ�Ȃ̂ŁA�ǉ����Ĉ�����ݒ肷��
    Set MyActualStartTime = MyTask.UserProperties.Add(USER_PROPERTY_NAME_ACTUAL_START_TIME, olDateTime)
    MyActualStartTime.Value = anActualStartTime
    Call MyTask.Save
End Property

' �I������
Public Property Get ActualEndTime() As Date
    If Not MyActualEndTime Is Nothing Then
        ActualEndTime = MyActualEndTime.Value
        Exit Property
    End If
    
    ' ���[�U�[��`�t�B�[���h�̎擾
    Set MyActualEndTime = MyTask.UserProperties.Find(USER_PROPERTY_NAME_ACTUAL_END_TIME)
    If Not MyActualEndTime Is Nothing Then
        ActualEndTime = MyActualEndTime.Value
        Exit Property
    End If
    
    ' �����܂ŗ���̂̓��[�U��`�t�B�[���h���Ȃ��ꍇ�Ȃ̂ŁA�ǉ����ď���������
    Set MyActualEndTime = MyTask.UserProperties.Add(USER_PROPERTY_NAME_ACTUAL_END_TIME, olDateTime)
    MyActualEndTime.Value = EMPTY_DATE_VALUE
    Call MyTask.Save

    ActualEndTime = MyActualEndTime.Value
End Property

Public Property Let ActualEndTime(ByVal anActualEndTime As Date)
    If Not MyActualEndTime Is Nothing Then
        MyActualEndTime.Value = anActualEndTime
        Call MyTask.Save
        Exit Property
    End If
    
    ' ���[�U�[��`�t�B�[���h�̎擾
    Set MyActualEndTime = MyTask.UserProperties.Find(USER_PROPERTY_NAME_ACTUAL_END_TIME)
    If Not MyActualEndTime Is Nothing Then
        MyActualEndTime.Value = anActualEndTime
        Call MyTask.Save
        Exit Property
    End If
    
    ' �����܂ŗ���̂̓��[�U��`�t�B�[���h���Ȃ��ꍇ�Ȃ̂ŁA�ǉ����Ĉ�����ݒ肷��
    Set MyActualEndTime = MyTask.UserProperties.Add(USER_PROPERTY_NAME_ACTUAL_END_TIME, olDateTime)
    MyActualEndTime.Value = anActualEndTime
    Call MyTask.Save
End Property

' ���ώ���
Public Property Get EstimatedTime() As Long
    If Not MyEstimatedTime Is Nothing Then
        EstimatedTime = MyEstimatedTime.Value
        Exit Property
    End If
    
    ' ���[�U�[��`�t�B�[���h�̎擾
    Set MyEstimatedTime = MyTask.UserProperties.Find(USER_PROPERTY_NAME_ESTIMATED_TIME)
    If Not MyEstimatedTime Is Nothing Then
        EstimatedTime = MyEstimatedTime.Value
        Exit Property
    End If
    
    ' �����܂ŗ���̂̓��[�U��`�t�B�[���h���Ȃ��ꍇ�Ȃ̂ŁA�ǉ����ď���������
    Set MyEstimatedTime = MyTask.UserProperties.Add(USER_PROPERTY_NAME_ESTIMATED_TIME, olDuration)
    MyEstimatedTime.Value = EMPTY_DATE_VALUE
    Call MyTask.Save

    EstimatedTime = MyEstimatedTime.Value
End Property

Public Property Let EstimatedTime(ByVal anEstimatedTime As Long)
    If Not MyEstimatedTime Is Nothing Then
        MyEstimatedTime.Value = anEstimatedTime
        Call MyTask.Save
        Exit Property
    End If
    
    ' ���[�U�[��`�t�B�[���h�̎擾
    Set MyEstimatedTime = MyTask.UserProperties.Find(USER_PROPERTY_NAME_ESTIMATED_TIME)
    If Not MyEstimatedTime Is Nothing Then
        MyEstimatedTime.Value = anEstimatedTime
        Call MyTask.Save
        Exit Property
    End If
    
    ' �����܂ŗ���̂̓��[�U��`�t�B�[���h���Ȃ��ꍇ�Ȃ̂ŁA�ǉ����Ĉ�����ݒ肷��
    Set MyEstimatedTime = MyTask.UserProperties.Add(USER_PROPERTY_NAME_ESTIMATED_TIME, olDuration)
    MyEstimatedTime.Value = anEstimatedTime
    Call MyTask.Save
End Property