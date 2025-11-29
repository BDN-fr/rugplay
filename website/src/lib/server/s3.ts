export async function generatePresignedUrl(key: string, contentType: string): Promise<string> {
    return new Promise((resolve, reject) => {
      resolve('')
    });
}

export async function deleteObject(key: string): Promise<void> {
    return new Promise((resolve, reject) => {
      resolve()
    });
}

export async function generateDownloadUrl(key: string): Promise<string> {
    return new Promise((resolve, reject) => {
      resolve('')
    });
}

export async function uploadProfilePicture(
    identifier: string, // Can be user ID or a unique ID from social provider
    body: Uint8Array,
    contentType: string,
): Promise<string> {
    throw new Error('No file can be uploaded');
}

export async function uploadCoinIcon(
    coinSymbol: string,
    body: Uint8Array,
    contentType: string,
): Promise<string> {
    throw new Error('No file can be uploaded');
}

export { s3Client };
