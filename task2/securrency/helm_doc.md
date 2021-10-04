<h1>How to create helm chart</h1></br>

    * helm create chart_name

<h1>which files extra need to be added to chart </h1></br>

    * to provoide EBS support as pv .

        {{- if .Values.volume.enabled -}}
        {{- if .Values.existingVolume.enabled -}}
        apiVersion: v1
        kind: PersistentVolume
        metadata:
        name: {{ .Values.volume.PVname }}
        spec:
        capacity:
            storage: {{ .Values.volume.storage }}
        volumeMode: Filesystem
        accessModes:
            - ReadWriteOnce
        storageClassName: ""
        csi:
            driver: ebs.csi.aws.com
            volumeHandle: {{ .Values.existingVolume.volumeID }}
            fsType: ext4
        nodeAffinity:
            required:
            nodeSelectorTerms:
            - matchExpressions:
                - key: topology.ebs.csi.aws.com/zone
                operator: In
                values:
                - {{ .Values.volume.region }}
        ---
        apiVersion: v1
        kind: PersistentVolumeClaim
        metadata:
        name: {{ .Values.volume.claimName }}
        spec:
        accessModes:
            - ReadWriteOnce
        storageClassName: ""
        resources:
            requests:
            storage: {{ .Values.volume.storage }}
        {{ else }}
        # if not then make new dynamic EBS
        apiVersion: storage.k8s.io/v1
        kind: StorageClass
        metadata:
        name: {{ .Values.volume.storageclass }}
        provisioner: ebs.csi.aws.com
        volumeBindingMode: Immediate
        reclaimPolicy: Retain
        allowVolumeExpansion: true
        parameters:
        csi.storage.k8s.io/fstype: ext4
        type: gp2
        encrypted: "true"
        allowedTopologies:
        - matchLabelExpressions:
        - key: topology.ebs.csi.aws.com/zone
            values:
            - {{ .Values.volume.region }}
        ---
        apiVersion: v1
        kind: PersistentVolumeClaim
        metadata:
        name: {{ .Values.volume.claimName }}
        spec:
        accessModes:
            - ReadWriteOnce
        storageClassName: {{ .Values.volume.storageclass }}
        resources:
            requests:
            storage: {{ .Values.volume.storage }}
        {{- end}}
        {{- end }}

    * to Provide EFS support as PV
        
        PVC remain same for both static and dynamic provisioning

        apiVersion: v1
        kind: PersistentVolumeClaim
        metadata:
        name: {{ .Values.volume.claimName }}
        spec:
        accessModes:
            - ReadWriteOnce
        storageClassName: ""
        resources:
            requests:
            storage: {{ .Values.volume.storageSize}}
        {{- end }}

        for static provisioning add below content to file.
        
        ---
        {{- if .Values.volume.enabled -}}
        apiVersion: v1
        kind: PersistentVolume
        metadata:
        name: {{ .Values.volume.PVname }}
        spec:
        capacity:
            storage: {{ .Values.volume.storageSize }}
        volumeMode: Filesystem
        accessModes:
            - ReadWriteOnce
        persistentVolumeReclaimPolicy: Retain
        storageClassName: ""
        csi:
            driver: efs.csi.aws.com
            volumeHandle: {{ .Values.volume.fsid }}
        ---
        for dynamic provisioning add below content to file.

        kind: StorageClass
        apiVersion: storage.k8s.io/v1
        metadata:
        name: efs-sci
        provisioner: efs.csi.aws.com
        parameters:
        provisioningMode: efs-ap
        fileSystemId: fs-d90d0b08
        directoryPerms: "700"
        basePath: "/dynamic" # folder_name

<h1>Now let's add volume support to our deployment.yaml file in chart > templates</h1></br>

    * spec:
    *  {{- if .Values.volume.enabled }}
      volumes:
        - name: {{ .Values.volume.PVname }}
          persistentVolumeClaim:
            claimName: {{ .Values.volume.claimName }}
      {{- end }} 
    *
      securityContext:
        {{- toYaml .Values.podSecurityContext | nindent 8 }}
      containers:
        - name: {{ .Chart.Name }}
          securityContext:

    image: {{ .Values.image.repository }}
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
      *   volumeMounts:
            - name: {{ .Values.volume.PVname }}
              mountPath: "/var/www/html"
      *


<h1>now let's add variables for the files we created for PV provisioning</h1></br>


    volume:
      enabled: true
      PVname: test-p
      storage: 7Gi
      claimName: test-c
      storageclass: testt
      region: ap-south-1a

    existingVolume:
      enabled: true
      volumeID: vol-0f14d42507b1eb2a0
      

<h1> Helm Chart varibales </h1> </br>

- this helm chart will help you to setup whole process of deploying Ingress, Service and deployment for AU wordpress website.

- chnage belowe variables in ./ams/values.yaml file</br>

    Format - variables ==> why it needs to be change.

        1.  replicaCount            - replica count will deploy number of pods which depends on client number list.
        2.  ingress.hosts.host      - it provides hostname for website (http). 
        3.  ingress.tls.host        - it provides hostname for website (ssl).
        4.  resources               - it provides CPU and memory resource to Pod.
        5.  autoscaling             - it provides min and max desire pod count accordingly.
        6.  volume.PVname           - Different PV will help to better management of data of websites.(giving different name will help to identify it in cluster and aws.)
        7.  volume.storage          - provide storage in EBS according to your needs. EX:7Gi, 10Gi.
        8.  volume.claimName        - No PVC can be same for multiple pods.every namespce should have different PVC to claim.
        9.  volume.storageclass     - giving different name to SC will help towards better management of namespace resources.
        10. volume.region           - provides functionality of EBS creation in any region user want.
        11. existingVolume.enabled  - if user want to move exisiting website than need to change this variable to true. 
        12. existingVolume.volumeID - if user want to move exisiting website than need to give EBS volume id to this variable.

<h1> Helm chart deployment command</h1> </br>

don't forgot to change mentioned variables above.

    - ./EBS_name.sh chart_name chart_path

    - Example : ./EBS_name.sh kangaroo ./ams

<h3>To increase the size of volume.</h3></br>

    -change to volume.storage to expected size 
    command : helm upgrade old_chart_name chart_path
    
     
