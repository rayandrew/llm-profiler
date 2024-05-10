from dlio_profiler.logger import dlio_logger as logger
from dlio_profiler.logger import fn_interceptor as dlp_event_logging
import numpy as np
import os
import torch
import torchvision
import torchvision.datasets as datasets
import torch
from torchmetrics.classification import MulticlassAccuracy
from torchmetrics.aggregation import MeanMetric
import torchvision.transforms as transforms
from torch.utils.data import DataLoader

import torch.nn as nn
import torch.nn.functional as F


EPOCHS = 10
dlp_pid = os.getpid()
log_inst = logger.initialize_log(
    logfile=f"./log/dlio/dlio_log_py_level-{dlp_pid}.pfw",
    # logfile=None,
    # data_dir=os.environ.get("DLIO_PROFILER_DATA_DIR", ""),
    data_dir=None,
    # process_id=-1,
    process_id=dlp_pid,
)
compute_dlp = dlp_event_logging("Compute")
io_dlp = dlp_event_logging("IO", name="real_IO")
transform = transforms.Compose(
    [transforms.ToTensor(), transforms.Normalize((0.5,), (0.5,))]
)
dlp = dlp_event_logging("torch")


class CustomFashionMNIST(torchvision.datasets.FashionMNIST):
    @dlp.log_init
    def __init__(
        self,
        root,
        train=True,
        transform=None,
        target_transform=None,
        download=False,
    ):
        super().__init__(
            root=root,
            train=train,
            transform=transform,
            target_transform=target_transform,
            download=download,
        )

    @dlp.log
    def _check_legacy_exist(self):
        return super()._check_legacy_exist()

    @dlp.log
    def __len__(self):
        return super().__len__()

    @dlp.log
    def _load_data(self):
        return super()._load_data()

    @dlp.log
    def __getitem__(self, index):
        return super().__getitem__(index)

    @dlp.log
    def download(self) -> None:
        return super().download()


class CustomDataLoader(DataLoader):
    @dlp.log_init
    def __init__(
        self,
        dataset,
        batch_size=1,
        shuffle=None,
        sampler=None,
        batch_sampler=None,
        num_workers: int = 0,
        collate_fn=None,
        pin_memory: bool = False,
        drop_last: bool = False,
        timeout: float = 0,
        worker_init_fn=None,
        multiprocessing_context=None,
        generator=None,
        *,
        prefetch_factor=None,
        persistent_workers: bool = False,
        pin_memory_device: str = "",
        **kwargs,
    ):
        super(CustomDataLoader, self).__init__(
            dataset=dataset,
            batch_size=batch_size,
            shuffle=shuffle,
            num_workers=num_workers,
            collate_fn=collate_fn,
            pin_memory=pin_memory,
            drop_last=drop_last,
            timeout=timeout,
            worker_init_fn=worker_init_fn,
            multiprocessing_context=multiprocessing_context,
            generator=generator,
            prefetch_factor=prefetch_factor,
            persistent_workers=persistent_workers,
            pin_memory_device=pin_memory_device,
            **kwargs,
        )

    @dlp.log
    def __iter__(self):
        return super().__iter__()

    @dlp.log
    def __next__(self):
        return super().__next__()

    @dlp.log
    def __len__(self):
        return super().__len__()


# training_set = datasets.MNIST(root='./data', train=True, download=True, transform=None)
# validation_set = datasets.MNIST(root='./data', train=False, download=True, transform=None)
training_set = CustomFashionMNIST(
    "./data", train=True, transform=transform, download=True
)
validation_set = CustomFashionMNIST(
    "./data", train=False, transform=transform, download=True
)

train_loader = CustomDataLoader(
    training_set, batch_size=4, shuffle=True, num_workers=4, persistent_workers=True
)
test_loader = CustomDataLoader(
    validation_set, batch_size=4, shuffle=False, num_workers=4, persistent_workers=True
)

classes = (
    "T-shirt/top",
    "Trouser",
    "Pullover",
    "Dress",
    "Coat",
    "Sandal",
    "Shirt",
    "Sneaker",
    "Bag",
    "Ankle Boot",
)


print("Training set has {} instances".format(len(training_set)))
print("Validation set has {} instances".format(len(validation_set)))


class GarmentClassifier(nn.Module):
    def __init__(self):
        super(GarmentClassifier, self).__init__()
        self.conv1 = nn.Conv2d(1, 6, 5)
        self.pool = nn.MaxPool2d(2, 2)
        self.conv2 = nn.Conv2d(6, 16, 5)
        self.fc1 = nn.Linear(16 * 4 * 4, 120)
        self.fc2 = nn.Linear(120, 84)
        self.fc3 = nn.Linear(84, 10)

    def forward(self, x):
        x = self.pool(F.relu(self.conv1(x)))
        x = self.pool(F.relu(self.conv2(x)))
        x = x.view(-1, 16 * 4 * 4)
        x = F.relu(self.fc1(x))
        x = F.relu(self.fc2(x))
        x = self.fc3(x)
        return x


def train_one_epoch(
    model,
    training_loader,
    optimizer,
    losses,
    accuracy_fn,
    top1_fn,
    top5_fn,
    accuracies,
    top1s,
    top5s,
    device,
    loss_fn,
    epoch_index,
):
    running_loss = 0.0
    last_loss = 0.0

    # Here, we use enumerate(training_loader) instead of
    # iter(training_loader) so that we can track the batch
    # index and do some intra-epoch reporting
    for i, (inputs, labels) in io_dlp.iter(enumerate(train_loader)):
        with dlp_event_logging(
            "train_communication-except-io",
            name="cpu-gpu-transfer",
            step=i,
            epoch=epoch,
        ) as transfer:
            inputs = inputs.to(device)
            labels = labels.to(device)

        # Zero your gradients for every batch!
        optimizer.zero_grad()

        with dlp_event_logging(
            "train_compute", name="model-compute-forward-prop", step=i, epoch=epoch
        ) as compute:
            outputs = model(inputs)
            loss = loss_fn(outputs, labels)

        with dlp_event_logging(
            "train_compute", name="model-compute-backward-prop", step=i, epoch=epoch
        ) as compute:
            loss.backward()
            optimizer.step()
            acc = accuracy_fn(outputs, labels)
            acc1 = top1_fn(outputs, labels)
            acc5 = top5_fn(outputs, labels)
            # Adjust learning weights
            losses.append(loss.cpu().item())
            accuracies.append(acc.cpu().item())
            top1s.append(acc1.cpu().item())
            top5s.append(acc5.cpu().item())

        # Gather data and report
        running_loss += loss.item()
        if i % 1000 == 999:
            last_loss = running_loss / 1000  # loss per batch
            print("  batch {} loss: {}".format(i + 1, last_loss))
            print("  batch {} accuracy: {}".format(i + 1, acc))

    return last_loss


device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
print("Using device: {}".format(device))

# model = torchvision.models.resnet50(pretrained=False)
model = GarmentClassifier()
criterion = torch.nn.CrossEntropyLoss().to(device)
model = model.to(device)
epoch_number = 0
accuracy_fn = MulticlassAccuracy(num_classes=10).to(device)
top1_fn = MulticlassAccuracy(num_classes=10, top_k=1).to(device)
top5_fn = MulticlassAccuracy(num_classes=10, top_k=5).to(device)

train_losses = []
train_accs = []
train_top1s = []
train_top5s = []

test_losses = []
test_accs = []
test_top1s = []
test_top5s = []


optimizer = torch.optim.SGD(model.parameters(), lr=0.001, momentum=0.9)
# From the train() function
for epoch in range(EPOCHS):
    print("EPOCH {}:".format(epoch_number + 1))
    model.train()
    train_one_epoch(
        model=model,
        training_loader=train_loader,
        optimizer=optimizer,
        losses=train_losses,
        accuracy_fn=accuracy_fn,
        top1_fn=top1_fn,
        top5_fn=top5_fn,
        accuracies=train_accs,
        top1s=train_top1s,
        top5s=train_top5s,
        device=device,
        loss_fn=criterion,
        epoch_index=epoch_number,
    )

    model.eval()
    with torch.no_grad():
        for i, (inputs, labels) in io_dlp.iter(enumerate(test_loader)):
            with dlp_event_logging(
                "test_communication-except-io",
                name="cpu-gpu-transfer",
                step=i,
                epoch=epoch,
            ) as transfer:
                inputs = inputs.to(device)
                labels = labels.to(device)

            with dlp_event_logging(
                "test_compute", name="model-compute-forward-prop", step=i, epoch=epoch
            ) as compute:
                outputs = model(inputs)
                loss = criterion(outputs, labels)

            with dlp_event_logging(
                "test_compute", name="metric-calculation", step=i, epoch=epoch
            ) as compute:
                acc = accuracy_fn(outputs, labels)
                acc1 = top1_fn(outputs, labels)
                acc5 = top5_fn(outputs, labels)
                loss = loss.cpu().item()
                test_losses.append(loss)
                test_accs.append(acc.cpu().item())
                test_top1s.append(acc1.cpu().item())

    print("  test loss: {}".format(np.mean(test_losses)))
    print("  test accuracy: {}".format(np.mean(test_accs)))
    print("  test top1 accuracy: {}".format(np.mean(test_accs)))
    print("  test top5 accuracy: {}".format(np.mean(test_top1s)))

    epoch_number += 1


# At the end of main function
log_inst.finalize()
