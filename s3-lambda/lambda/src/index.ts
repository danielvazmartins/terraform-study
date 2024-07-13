import { Context, S3Event } from 'aws-lambda';
import { GetObjectCommand, S3Client } from '@aws-sdk/client-s3';

const s3Client = new S3Client({});

export const app = async (event: S3Event, context: Context) => {
    console.log("Event:", JSON.stringify(event));
    console.log("Context:", JSON.stringify(context));
    
    const bucketName = event.Records[0].s3.bucket.name;
    const bucketArn = event.Records[0].s3.bucket.arn;
    const fileName = event.Records[0].s3.object.key;
    console.log("bucketName", bucketName);
    console.log("bucketArn", bucketArn);
    console.log("fileName", fileName);

    const s3Object = await s3Client.send(
        new GetObjectCommand({
            Bucket: bucketName,
            Key: fileName,
        })
    );
    
    console.log("Json Content:")
    console.log(await s3Object.Body?.transformToString());
    
    return {
        statusCode: 200,
        message: 'Lambda executada com sucesso!'
    }
};